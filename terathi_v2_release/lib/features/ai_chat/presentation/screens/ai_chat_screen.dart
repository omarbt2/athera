import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/monuments_provider.dart';
import '../../../../shared/domain/entities/monument.dart';

// ── Models ──────────────────────────────────────────────────────────────────

enum _MsgRole { user, ai }

class _Msg {
  final _MsgRole role;
  final String text;
  final DateTime time;
  bool isStreaming;

  _Msg({
    required this.role,
    required this.text,
    this.isStreaming = false,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

// ── Provider ─────────────────────────────────────────────────────────────────

class _ChatNotifier extends StateNotifier<List<_Msg>> {
  _ChatNotifier(this._monument) : super([]) {
    _init();
  }

  final Monument _monument;
  bool isLoading = false;
  GenerativeModel? _model;
  ChatSession? _chat;

  void _init() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.system(
          '''أنت مرشد Athera ذكي ومتخصص في التراث الجزائري. اسمك "تراث". 
          أنت الآن تتحدث عن "${_monument.name.ar}" الواقع في ${_monument.wilaya}.
          معلومات المعلم: ${_monument.description.ar}
          الحقبة التاريخية: ${_monument.historicalEra}
          
          قواعدك:
          - أجب دائماً بالعربية الفصحى البسيطة
          - أجوبتك مختصرة وشيقة (2-4 جمل)
          - استخدم الإيموجي بشكل معتدل
          - لا تخرج عن موضوع التراث الجزائري
          - كن حماساً ومشجعاً على الاستكشاف''',
        ),
      );
      _chat = _model!.startChat();

      // Welcome message
      state = [
        _Msg(
          role: _MsgRole.ai,
          text:
              'مرحباً! أنا مرشدك الذكي لاستكشاف ${_monument.name.ar} 🏛️\nاسألني عن تاريخها، معمارها، أو أي شيء يثير فضولك!',
        ),
      ];
    } catch (e) {
      state = [
        _Msg(
          role: _MsgRole.ai,
          text:
              'مرحباً! أنا مرشدك لاستكشاف ${_monument.name.ar} 🏛️\nاسألني عن تاريخها وحضارتها!',
        ),
      ];
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading) return;
    isLoading = true;

    // Add user message
    state = [...state, _Msg(role: _MsgRole.user, text: text.trim())];

    // Add empty AI message (streaming)
    final aiMsg = _Msg(role: _MsgRole.ai, text: '', isStreaming: true);
    state = [...state, aiMsg];
    final aiIndex = state.length - 1;

    try {
      if (_chat == null) {
        // Fallback offline responses
        await Future.delayed(const Duration(milliseconds: 800));
        final responses = _offlineResponses(_monument, text);
        _updateAiMsg(aiIndex, responses, streaming: false);
      } else {
        final response = _chat!.sendMessageStream(Content.text(text.trim()));
        final buffer = StringBuffer();
        await for (final chunk in response) {
          buffer.write(chunk.text ?? '');
          _updateAiMsg(aiIndex, buffer.toString(), streaming: true);
          await Future.delayed(const Duration(milliseconds: 30));
        }
        _updateAiMsg(aiIndex, buffer.toString(), streaming: false);
      }
    } catch (e) {
      _updateAiMsg(
        aiIndex,
        'عذراً، حدث خطأ في الاتصال. تأكد من الإنترنت وحاول مجدداً 🔄',
        streaming: false,
      );
    }

    isLoading = false;
  }

  void _updateAiMsg(int index, String text, {required bool streaming}) {
    final updated = List<_Msg>.from(state);
    if (index < updated.length) {
      updated[index] = _Msg(
        role: _MsgRole.ai,
        text: text,
        isStreaming: streaming,
        time: updated[index].time,
      );
      state = updated;
    }
  }

  String _offlineResponses(Monument m, String query) {
    final q = query.toLowerCase();
    if (q.contains('تاريخ') || q.contains('متى') || q.contains('بني')) {
      return 'تعود ${m.name.ar} إلى ${m.historicalEra}، وهي شاهدة على حضارة عريقة تمتد لآلاف السنين في قلب الجزائر 🌟';
    } else if (q.contains('موقع') || q.contains('أين') || q.contains('ولاية')) {
      return '${m.name.ar} تقع في ولاية ${m.wilaya}، وهي من أبرز المعالم الAtheraة في المنطقة وتستقطب آلاف الزوار سنوياً 📍';
    } else if (q.contains('معمار') || q.contains('بناء') || q.contains('طراز')) {
      return 'يتميز معمار ${m.name.ar} بأسلوب ${m.historicalEra} الفريد، حيث تجمع بين الجمال الفني والوظيفة التاريخية بشكل رائع 🏛️';
    } else if (q.contains('يونسكو') || q.contains('عالمي')) {
      return m.isUNESCO
          ? '${m.name.ar} مصنفة ضمن مواقع التراث العالمي لليونسكو، مما يعكس قيمتها الاستثنائية للإنسانية جمعاء 🌍✨'
          : 'رغم قيمتها الكبيرة، ${m.name.ar} لم تُصنف بعد من قِبل اليونسكو، لكنها تستحق كل الاهتمام والحفاظ 💎';
    }
    return '${m.name.ar} كنز تاريخي حقيقي يحكي قصة حضارة عريقة. هل تريد أن أخبرك عن تاريخها، معمارها، أو موقعها؟ 🏺';
  }
}

// ── Suggested Questions ──────────────────────────────────────────────────────

const List<String> _suggestions = [
  'متى بُني هذا المعلم؟',
  'ما أبرز ما يميزه؟',
  'كيف أصل إليه؟',
  'لماذا هو مهم تاريخياً؟',
];

// ── Screen ───────────────────────────────────────────────────────────────────

class AiChatScreen extends ConsumerStatefulWidget {
  final String monumentId;
  const AiChatScreen({super.key, required this.monumentId});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  bool _showSuggestions = true;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final monumentAsync =
        ref.watch(monumentDetailProvider(widget.monumentId));

    return monumentAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: Center(child: Text(e.toString())),
      ),
      data: (monument) {
        final chatProvider = StateNotifierProvider<_ChatNotifier, List<_Msg>>(
          (ref) => _ChatNotifier(monument),
        );
        return _ChatBody(
          monument: monument,
          chatProvider: chatProvider,
          textCtrl: _textCtrl,
          scrollCtrl: _scrollCtrl,
          focusNode: _focusNode,
          showSuggestions: _showSuggestions,
          onSend: (text) {
            if (text.trim().isEmpty) return;
            setState(() => _showSuggestions = false);
            _textCtrl.clear();
            ref.read(chatProvider.notifier).sendMessage(text);
            _scrollToBottom();
          },
          onSuggestion: (s) {
            setState(() => _showSuggestions = false);
            ref.read(chatProvider.notifier).sendMessage(s);
            _scrollToBottom();
          },
        );
      },
    );
  }
}

class _ChatBody extends ConsumerWidget {
  final Monument monument;
  final StateNotifierProvider<_ChatNotifier, List<_Msg>> chatProvider;
  final TextEditingController textCtrl;
  final ScrollController scrollCtrl;
  final FocusNode focusNode;
  final bool showSuggestions;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onSuggestion;

  const _ChatBody({
    required this.monument,
    required this.chatProvider,
    required this.textCtrl,
    required this.scrollCtrl,
    required this.focusNode,
    required this.showSuggestions,
    required this.onSend,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (_, i) => _MessageBubble(
                  msg: messages[i],
                  index: i,
                ),
              ),
            ),

            // Suggestions
            if (showSuggestions)
              _SuggestionsRow(
                suggestions: _suggestions,
                onTap: onSuggestion,
              ),

            // Input bar
            _InputBar(
              controller: textCtrl,
              focusNode: focusNode,
              isLoading: notifier.isLoading,
              onSend: () => onSend(textCtrl.text),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.logoTeal, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المرشد الذكي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'متصل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded,
              color: AppColors.textSecondary),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Show monument info bottom sheet
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// ── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  final int index;
  const _MessageBubble({required this.msg, required this.index});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == _MsgRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          // AI avatar
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.logoTeal, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight:
                      isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? AppColors.primary : Colors.black)
                        .withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isUser
                    ? null
                    : Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
              ),
              child: msg.isStreaming && msg.text.isEmpty
                  ? _TypingIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                            height: 1.55,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        if (msg.isStreaming) ...[
                          const SizedBox(height: 4),
                          _streamingCursor(),
                        ],
                      ],
                    ),
            ),
          ),

          // User avatar
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Icon(Icons.person_rounded,
                  size: 18, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.12, end: 0, duration: 300.ms);
  }

  Widget _streamingCursor() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.logoTeal,
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 500.ms),
      ],
    );
  }
}

// ── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(
          reverse: true,
          period: Duration(milliseconds: 900 + i * 150),
        ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(left: i < 2 ? 4 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.logoTeal.withValues(
                  alpha: 0.4 + 0.6 * _controllers[i].value),
            ),
          ),
        );
      }),
    );
  }
}

// ── Suggestions Row ──────────────────────────────────────────────────────────

class _SuggestionsRow extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _SuggestionsRow({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أسئلة مقترحة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(suggestions[i]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        suggestions[i],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Input Bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              width: 1),
        ),
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.outlineVariant, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      maxLines: 4,
                      minLines: 1,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'اسألني عن هذا المعلم...',
                        hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                    isLoading ? AppColors.textTertiary : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color:
                              AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}