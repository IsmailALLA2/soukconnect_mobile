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
import '../../domain/entities/user_entity.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Moroccan wilayas (12 regions)
// ─────────────────────────────────────────────────────────────────────────────

const _wilayas = [
  'Tanger-Tétouan-Al Hoceïma',
  'L\'Oriental',
  'Fès-Meknès',
  'Rabat-Salé-Kénitra',
  'Béni Mellal-Khénifra',
  'Casablanca-Settat',
  'Marrakech-Safi',
  'Drâa-Tafilalet',
  'Souss-Massa',
  'Guelmim-Oued Noun',
  'Laâyoune-Sakia El Hamra',
  'Dakhla-Oued Ed-Dahab',
];

// ─────────────────────────────────────────────────────────────────────────────
// RegisterPage
// ─────────────────────────────────────────────────────────────────────────────

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Step & role state ─────────────────────────────────────────────────
    final currentStep    = useState(0);
    final selectedRole   = useState<UserRole>(UserRole.detaillant);

    // ── Text controllers ──────────────────────────────────────────────────
    final fullNameCtrl   = useTextEditingController();
    final phoneCtrl      = useTextEditingController();
    final emailCtrl      = useTextEditingController();
    final passwordCtrl   = useTextEditingController();

    // ── Local UI state ────────────────────────────────────────────────────
    final showPassword   = useState(false);
    final selectedWilaya = useState<String?>(null);

    // ── Step transition animation ─────────────────────────────────────────
    final animCtrl = useAnimationController(
      duration: const Duration(milliseconds: 450),
      initialValue: 1.0,
    );

    final fadeAnim = useMemoized(
      () => CurvedAnimation(parent: animCtrl, curve: Curves.easeInOut),
      [animCtrl],
    );

    Future<void> animateToStep(int step) async {
      await animCtrl.reverse();
      currentStep.value = step;
      await animCtrl.forward();
    }

    // ── Page enter animation ──────────────────────────────────────────────
    final pageAnimCtrl = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    useEffect(() {
      pageAnimCtrl.forward();
      return null;
    }, const []);

    final pageFade = useMemoized(
      () => CurvedAnimation(parent: pageAnimCtrl, curve: Curves.easeOut),
      [pageAnimCtrl],
    );
    final pageSlide = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.05),
        end:   Offset.zero,
      ).animate(CurvedAnimation(parent: pageAnimCtrl, curve: Curves.easeOut)),
      [pageAnimCtrl],
    );

    // ── Provider state ────────────────────────────────────────────────────
    final form  = ref.watch(authFormProvider);
    final formN = ref.read(authFormProvider.notifier);
    final authN = ref.read(authNotifierProvider.notifier);

    // Sync controllers → form
    useEffect(() {
      void syncName()  => formN.updateFullName(fullNameCtrl.text);
      void syncPhone() => formN.updatePhone(phoneCtrl.text);
      void syncEmail() => formN.updateEmail(emailCtrl.text);
      void syncPass()  => formN.updatePassword(passwordCtrl.text);

      fullNameCtrl.addListener(syncName);
      phoneCtrl.addListener(syncPhone);
      emailCtrl.addListener(syncEmail);
      passwordCtrl.addListener(syncPass);

      return () {
        fullNameCtrl.removeListener(syncName);
        phoneCtrl.removeListener(syncPhone);
        emailCtrl.removeListener(syncEmail);
        passwordCtrl.removeListener(syncPass);
      };
    }, const []);

    // ── Submit ────────────────────────────────────────────────────────────
    Future<void> handleSignUp() async {
      FocusScope.of(context).unfocus();
      formN.updateRole(selectedRole.value);
      formN.updateWilaya(selectedWilaya.value ?? '');
      if (!formN.validateSignUp()) return;

      formN.setLoading(true);
      try {
        await authN.signUp(
          email:    form.email,
          password: form.password,
          fullName: form.fullName,
          phone:    form.phone,
          wilaya:   selectedWilaya.value ?? '',
          role:     selectedRole.value,
        );
        // GoRouter redirect handles navigation
      } on Failure catch (e) {
        formN.setError(e.message);
      } catch (_) {
        formN.setError('Une erreur inattendue est survenue.');
      }
    }

    final l10n = AppLocalizations.of(context);

    // ── Scaffold ──────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: pageFade,
          child: SlideTransition(
            position: pageSlide,
            child: Column(
              children: [
                // ── Progress header ───────────────────────────────────────
                _StepHeader(
                  currentStep: currentStep.value,
                  onBack: currentStep.value == 1
                      ? () => animateToStep(0)
                      : () => context.go(AppRoutes.login),
                ),

                // ── Scrollable body ───────────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: currentStep.value == 0
                          ? _Step1RoleSelector(
                              selectedRole: selectedRole.value,
                              l10n:         l10n,
                              onRoleSelect: (r) => selectedRole.value = r,
                              onNext: () => animateToStep(1),
                            )
                          : _Step2InfoForm(
                              fullNameCtrl:   fullNameCtrl,
                              phoneCtrl:      phoneCtrl,
                              emailCtrl:      emailCtrl,
                              passwordCtrl:   passwordCtrl,
                              showPassword:   showPassword,
                              selectedWilaya: selectedWilaya,
                              form:           form,
                              l10n:           l10n,
                              onSubmit:       handleSignUp,
                            ),
                    ),
                  ),
                ),

                // ── Login link (always visible at bottom) ─────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h, top: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          'Se connecter',
                          style: AppTextStyles.labelMedium(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step header with back button + step dots
// ─────────────────────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.currentStep,
    required this.onBack,
  });

  final int        currentStep;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Back / close button
          IconButton(
            icon: Icon(
              currentStep == 0 ? Icons.close : Icons.arrow_back_ios_new_rounded,
              color: context.colorScheme.onSurface,
              size: 20.sp,
            ),
            onPressed: onBack,
          ),

          const Spacer(),

          // Step dots
          Row(
            children: List.generate(2, (i) {
              final active = i == currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve:    Curves.easeInOut,
                margin:   EdgeInsets.symmetric(horizontal: 3.w),
                width:    active ? 20.w : 8.w,
                height:   8.h,
                decoration: BoxDecoration(
                  color:        active ? AppColors.primary : AppColors.grey300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),

          const Spacer(),
          SizedBox(width: 40.w), // balance the back button
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Role selector
// ─────────────────────────────────────────────────────────────────────────────

class _Step1RoleSelector extends StatelessWidget {
  const _Step1RoleSelector({
    required this.selectedRole,
    required this.l10n,
    required this.onRoleSelect,
    required this.onNext,
  });

  final UserRole  selectedRole;
  final AppLocalizations l10n;
  final ValueChanged<UserRole> onRoleSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 24.h),
        const AuthBrandLogo(),
        SizedBox(height: 28.h),

        Text(
          'Je suis...',
          style: AppTextStyles.headlineMedium(
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Choisissez votre rôle pour commencer',
          style: AppTextStyles.bodyMedium(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 36.h),

        // Grossiste card
        _RoleCard(
          icon:        Icons.warehouse_rounded,
          title:       l10n.grossiste,
          description: 'Je vends en gros à des détaillants',
          role:        UserRole.grossiste,
          isSelected:  selectedRole == UserRole.grossiste,
          onTap:       () => onRoleSelect(UserRole.grossiste),
        ),
        SizedBox(height: 16.h),

        // Détaillant card
        _RoleCard(
          icon:        Icons.storefront_rounded,
          title:       l10n.detaillant,
          description: 'Je cherche des fournisseurs grossistes',
          role:        UserRole.detaillant,
          isSelected:  selectedRole == UserRole.detaillant,
          onTap:       () => onRoleSelect(UserRole.detaillant),
        ),
        SizedBox(height: 36.h),

        AuthSubmitButton(
          label:     'Suivant →',
          isLoading: false,
          onPressed: onNext,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role card
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String   title;
  final String   description;
  final UserRole role;
  final bool     isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve:    Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey200,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color:      AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color:      AppColors.shadow,
                  blurRadius: 8,
                  offset:     const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.white : AppColors.grey600,
                    size:  26.sp,
                  ),
                ),
                SizedBox(width: 16.w),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium(
                          color: isSelected
                              ? AppColors.primary
                              : context.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Container(
                    width:  24.w,
                    height: 24.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size:  14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Personal info form
// ─────────────────────────────────────────────────────────────────────────────

class _Step2InfoForm extends StatelessWidget {
  const _Step2InfoForm({
    required this.fullNameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.showPassword,
    required this.selectedWilaya,
    required this.form,
    required this.l10n,
    required this.onSubmit,
  });

  final TextEditingController fullNameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final ValueNotifier<bool>    showPassword;
  final ValueNotifier<String?> selectedWilaya;
  final AuthFormState          form;
  final AppLocalizations       l10n;
  final VoidCallback           onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20.h),

        Text(
          'Vos informations',
          style: AppTextStyles.headlineSmall(
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Text(
          'Remplissez vos coordonnées pour créer votre compte',
          style: AppTextStyles.bodySmall(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 28.h),

        // ── Error banner ───────────────────────────────────────────────────
        if (form.errorMessage != null) ...[
          AuthErrorBanner(message: form.errorMessage!),
          SizedBox(height: 16.h),
        ],

        // ── Full name ──────────────────────────────────────────────────────
        AuthFieldLabel(l10n.fullName),
        SizedBox(height: 6.h),
        TextFormField(
          controller:      fullNameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.bodyLarge(color: context.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText:   'Hassan Alami',
            prefixIcon: const Icon(Icons.person_outline),
            errorText:  form.fullNameError,
          ),
        ),
        SizedBox(height: 16.h),

        // ── Phone ──────────────────────────────────────────────────────────
        AuthFieldLabel(l10n.phone),
        SizedBox(height: 6.h),
        TextFormField(
          controller:      phoneCtrl,
          keyboardType:    TextInputType.phone,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.bodyLarge(color: context.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText:   '06XXXXXXXX',
            prefixIcon: const Icon(Icons.phone_outlined),
            errorText:  form.phoneError,
          ),
        ),
        SizedBox(height: 16.h),

        // ── Email ──────────────────────────────────────────────────────────
        AuthFieldLabel(l10n.email),
        SizedBox(height: 6.h),
        TextFormField(
          controller:      emailCtrl,
          keyboardType:    TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect:     false,
          style: AppTextStyles.bodyLarge(color: context.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText:   'exemple@email.com',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText:  form.emailError,
          ),
        ),
        SizedBox(height: 16.h),

        // ── Password ───────────────────────────────────────────────────────
        AuthFieldLabel(l10n.password),
        SizedBox(height: 6.h),
        ValueListenableBuilder<bool>(
          valueListenable: showPassword,
          builder: (_, visible, child) => TextFormField(
            controller:      passwordCtrl,
            obscureText:     !visible,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyLarge(color: context.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText:   '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              errorText:  form.passwordError,
              suffixIcon: IconButton(
                icon: Icon(
                  visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grey500,
                  size:  20.sp,
                ),
                onPressed: () => showPassword.value = !showPassword.value,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Wilaya ─────────────────────────────────────────────────────────
        AuthFieldLabel(l10n.wilaya),
        SizedBox(height: 6.h),
        ValueListenableBuilder<String?>(
          valueListenable: selectedWilaya,
          builder: (_, wilaya, child) => _WilayaDropdown(
            value:     wilaya,
            error:     form.wilayaError,
            onChanged: (v) => selectedWilaya.value = v,
          ),
        ),
        SizedBox(height: 32.h),

        // ── Submit button ──────────────────────────────────────────────────
        AuthSubmitButton(
          label:     "S'inscrire",
          isLoading: form.isLoading,
          onPressed: onSubmit,
        ),
        SizedBox(height: 8.h),

        // ── Terms note ─────────────────────────────────────────────────────
        Text(
          'En créant un compte, vous acceptez nos Conditions d\'utilisation.',
          style: AppTextStyles.bodySmall(color: AppColors.grey400),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wilaya dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _WilayaDropdown extends StatelessWidget {
  const _WilayaDropdown({
    required this.value,
    required this.error,
    required this.onChanged,
  });

  final String?  value;
  final String?  error;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color:        theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (value != null ? AppColors.primary : AppColors.grey200),
              width: (hasError || value != null) ? 1.5 : 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:         value,
              isExpanded:    true,
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'Sélectionnez votre région',
                  style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              icon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey500,
                  size:  22.sp,
                ),
              ),
              borderRadius: BorderRadius.circular(12.r),
              dropdownColor: theme.colorScheme.surface,
              items: _wilayas
                  .map((w) => DropdownMenuItem(
                        value: w,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            w,
                            style: AppTextStyles.bodyMedium(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              error!,
              style: AppTextStyles.labelSmall(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }
}
