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
import '../providers/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginPage
// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Controllers & local state ─────────────────────────────────────────
    final emailCtrl    = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final showPassword = useState(false);
    final animCtrl     = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );

    // Start fade+slide on first frame
    useEffect(() {
      animCtrl.forward();
      return null;
    }, const []);

    final fadeAnim = useMemoized(
      () => CurvedAnimation(parent: animCtrl, curve: Curves.easeOut),
      [animCtrl],
    );
    final slideAnim = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeOut)),
      [animCtrl],
    );

    // ── Provider watchers ─────────────────────────────────────────────────
    final form  = ref.watch(authFormProvider);
    final formN = ref.read(authFormProvider.notifier);
    final authN = ref.read(authNotifierProvider.notifier);

    // Keep form state in sync with text controllers
    useEffect(() {
      void syncEmail() => formN.updateEmail(emailCtrl.text);
      void syncPass()  => formN.updatePassword(passwordCtrl.text);
      emailCtrl.addListener(syncEmail);
      passwordCtrl.addListener(syncPass);
      return () {
        emailCtrl.removeListener(syncEmail);
        passwordCtrl.removeListener(syncPass);
      };
    }, const []);

    // ── Submit ────────────────────────────────────────────────────────────
    Future<void> handleSignIn() async {
      FocusScope.of(context).unfocus();
      if (!formN.validateSignIn()) return;

      formN.setLoading(true);
      try {
        await authN.signIn(
          email:    form.email,
          password: form.password,
        );
        // GoRouter redirect handles navigation after successful sign-in
      } on Failure catch (e) {
        formN.setError(e.message);
      } catch (_) {
        formN.setError('Une erreur inattendue est survenue.');
      } finally {
        formN.setLoading(false);
      }
    }

    final l10n = AppLocalizations.of(context);

    // ── Scaffold ──────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
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
                      SizedBox(height: 56.h),

                      // ── Brand logo ──────────────────────────────────────
                      const AuthBrandLogo(),
                      SizedBox(height: 12.h),

                      // ── Page title ─────────────────────────────────────
                      Text(
                        l10n.login,
                        style: AppTextStyles.headlineMedium(
                          color: context.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Connectez-vous à votre compte',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.grey500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40.h),

                      // ── Error banner ────────────────────────────────────
                      if (form.errorMessage != null) ...[
                        AuthErrorBanner(message: form.errorMessage!),
                        SizedBox(height: 16.h),
                      ],

                      // ── Email ───────────────────────────────────────────
                      AuthFieldLabel(l10n.email),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller:      emailCtrl,
                        keyboardType:    TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect:     false,
                        style: AppTextStyles.bodyLarge(
                          color: context.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText:   'exemple@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          errorText:  form.emailError,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Password ────────────────────────────────────────
                      AuthFieldLabel(l10n.password),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller:       passwordCtrl,
                        obscureText:      !showPassword.value,
                        textInputAction:  TextInputAction.done,
                        onFieldSubmitted: (_) => handleSignIn(),
                        style: AppTextStyles.bodyLarge(
                          color: context.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText:   '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorText:  form.passwordError,
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
                      ),
                      SizedBox(height: 8.h),

                      // ── Forgot password ─────────────────────────────────
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () { /* TODO: forgot password flow */ },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 4.h,
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
                      SizedBox(height: 28.h),

                      // ── Sign-in button ──────────────────────────────────
                      AuthSubmitButton(
                        label:     'Se connecter',
                        isLoading: form.isLoading,
                        onPressed: handleSignIn,
                      ),
                      SizedBox(height: 24.h),

                      // ── Or divider ──────────────────────────────────────
                      const AuthOrDivider(),
                      SizedBox(height: 24.h),

                      // ── Spacer pushes register link to bottom ───────────
                      const Spacer(),

                      // ── Register link ───────────────────────────────────
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
      ),
    );
  }
}

