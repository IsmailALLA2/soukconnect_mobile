import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/green_spinner.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/widgets.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final showPassword = useState(false);
    final animCtrl = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final shimmerCtrl = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    useEffect(() {
      animCtrl.forward();
      shimmerCtrl.repeat();
      return null;
    }, const []);

    final fadeAnim = useMemoized(
      () => CurvedAnimation(parent: animCtrl, curve: Curves.easeOut),
      [animCtrl],
    );

    final form = ref.watch(authFormProvider);
    final formN = ref.read(authFormProvider.notifier);
    final authN = ref.read(authNotifierProvider.notifier);
    final isSuccess = useState(false);
    final errorCount = useRef(0);

    useEffect(() {
      void syncEmail() => formN.updateEmail(emailCtrl.text);
      void syncPass() => formN.updatePassword(passwordCtrl.text);
      emailCtrl.addListener(syncEmail);
      passwordCtrl.addListener(syncPass);
      return () {
        emailCtrl.removeListener(syncEmail);
        passwordCtrl.removeListener(syncPass);
      };
    }, const []);

    Future<void> handleSignIn() async {
      FocusScope.of(context).unfocus();
      if (!formN.validateSignIn()) return;
      formN.setLoading(true);
      try {
        await authN.signIn(email: form.email, password: form.password);
        isSuccess.value = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) isSuccess.value = false;
        });
      } on Failure catch (e) {
        formN.setError(e.message);
        errorCount.value++;
      } catch (_) {
        formN.setError('Une erreur inattendue est survenue.');
        errorCount.value++;
      } finally {
        if (context.mounted) formN.setLoading(false);
      }
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnim,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: context.screenHeight -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Top decorative section ────────────────────────
                    SizedBox(
                      height: 180.h,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipPath(
                            clipper: _WaveClipper(),
                            child: Container(
                              height: 160.h,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          // Decorative circles
                          Positioned(
                            right: -20.w,
                            top: -10.h,
                            child: _DecorativeCircle(
                              size: 80.w,
                              color: AppColors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          Positioned(
                            left: -30.w,
                            top: 40.h,
                            child: _DecorativeCircle(
                              size: 60.w,
                              color: AppColors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          Positioned(
                            right: 40.w,
                            top: 60.h,
                            child: _DecorativeCircle(
                              size: 40.w,
                              color: AppColors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          // Brand logo
                          Positioned(
                            bottom: -10.h,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Container(
                                  width: 64.w,
                                  height: 64.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(18.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                const Text(
                                  'SoukConnect',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // ── Title ─────────────────────────────────────────
                    Text(
                      l10n.login,
                      style: AppTextStyles.headlineMedium(
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Connectez-vous à votre compte',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.grey500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28.h),

                    // ── Form fields with shake on error ───────────────
                    _ShakeForm(
                      shakeKey: errorCount.value,
                      child: Column(
                        children: [
                          if (form.errorMessage != null) ...[
                            AuthErrorBanner(message: form.errorMessage!),
                            SizedBox(height: 16.h),
                          ],

                          // ── Email ────────────────────────────────────
                          AuthFieldLabel(l10n.email),
                          SizedBox(height: 6.h),
                          _AnimatedInputField(
                            focusNode: emailFocus,
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            hintText: 'exemple@email.com',
                            prefixIcon: Icons.email_outlined,
                            errorText: form.emailError,
                          ),
                          SizedBox(height: 20.h),

                          // ── Password ──────────────────────────────────
                          AuthFieldLabel(l10n.password),
                          SizedBox(height: 6.h),
                          _AnimatedInputField(
                            focusNode: passwordFocus,
                            controller: passwordCtrl,
                            obscureText: !showPassword.value,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => handleSignIn(),
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            errorText: form.passwordError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.grey500,
                                size: 20.sp,
                              ),
                              onPressed: () =>
                                  showPassword.value = !showPassword.value,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // ── Forgot password ───────────────────────────
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.h,
                          ),
                        ),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTextStyles.labelMedium(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Sign-in button ────────────────────────────────
                    _GradientSubmitButton(
                      label: 'Se connecter',
                      isLoading: form.isLoading,
                      isSuccess: isSuccess.value,
                      shimmerCtrl: shimmerCtrl,
                      onPressed: handleSignIn,
                    ),
                    SizedBox(height: 24.h),

                    // ── Or divider ────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'Ou continuer avec',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.grey500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // ── Social buttons ────────────────────────────────
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.login_rounded,
                          size: 20.sp, color: AppColors.grey700),
                      label: Text(
                        'Continuer avec Google',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.grey700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ── Register link ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas de compte ? ',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.grey500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(
                            l10n.register,
                            style: AppTextStyles.labelMedium(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    final firstCtrl = Offset(size.width / 4, size.height);
    final firstEnd = Offset(size.width / 2, size.height - 10);
    path.quadraticBezierTo(
      firstCtrl.dx, firstCtrl.dy, firstEnd.dx, firstEnd.dy,
    );
    final secondCtrl = Offset(size.width * 3 / 4, size.height - 30);
    final secondEnd = Offset(size.width, size.height - 15);
    path.quadraticBezierTo(
      secondCtrl.dx, secondCtrl.dy, secondEnd.dx, secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AnimatedInputField extends HookConsumerWidget {
  const _AnimatedInputField({
    required this.focusNode,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onSubmitted,
    required this.hintText,
    required this.prefixIcon,
    this.errorText,
    this.suffixIcon,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final String hintText;
  final IconData prefixIcon;
  final String? errorText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFocused = useState(false);

    useEffect(() {
      void onFocus() => isFocused.value = focusNode.hasFocus;
      focusNode.addListener(onFocus);
      return () => focusNode.removeListener(onFocus);
    }, [focusNode]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: errorText != null
              ? AppColors.error
              : isFocused.value
                  ? AppColors.primary
                  : AppColors.grey200,
          width: isFocused.value ? 1.5 : 1.0,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onFieldSubmitted: onSubmitted,
        autocorrect: false,
        style: AppTextStyles.bodyLarge(
          color: context.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, size: 20.sp),
          errorText: errorText,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: true,
          fillColor: context.colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}

class _GradientSubmitButton extends StatefulWidget {
  const _GradientSubmitButton({
    required this.label,
    required this.isLoading,
    required this.isSuccess,
    required this.shimmerCtrl,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final bool isSuccess;
  final AnimationController shimmerCtrl;
  final VoidCallback onPressed;

  @override
  State<_GradientSubmitButton> createState() => _GradientSubmitButtonState();
}

class _GradientSubmitButtonState extends State<_GradientSubmitButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: widget.isLoading
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                    AppColors.primary,
                  ],
                  stops: [
                    widget.shimmerCtrl.value * 0.0,
                    widget.shimmerCtrl.value.clamp(0.3, 0.7),
                    widget.shimmerCtrl.value.clamp(0.7, 1.0),
                  ],
                )
              : widget.isSuccess
                  ? const LinearGradient(
                      colors: [AppColors.success, Color(0xFF43A047)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: widget.isLoading
                    ? const GreenSpinner(size: 22, color: AppColors.white)
                    : widget.isSuccess
                        ? const Icon(Icons.check_rounded,
                            size: 26, color: AppColors.white)
                        : Text(
                            widget.label,
                            key: const ValueKey('label'),
                            style: AppTextStyles.titleSmall(
                                color: AppColors.white),
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShakeForm extends StatefulWidget {
  const _ShakeForm({required this.shakeKey, required this.child});
  final int shakeKey;
  final Widget child;

  @override
  State<_ShakeForm> createState() => _ShakeFormState();
}

class _ShakeFormState extends State<_ShakeForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(8, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(8, 0), end: const Offset(-6, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-6, 0), end: const Offset(4, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(4, 0), end: const Offset(-2, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-2, 0), end: Offset.zero), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_ShakeForm old) {
    super.didUpdateWidget(old);
    if (old.shakeKey != widget.shakeKey) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: _anim.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}
