import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/locale_provider.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/sizer.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/green_spinner.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final _wilayas = [
  'Casablanca-Settat',
  'Rabat-Salé-Kénitra',
  'Marrakech-Safi',
  'Fès-Meknès',
  'Tanger-Tétouan-Al Hoceïma',
  'Souss-Massa',
  'Oriental',
  'Béni Mellal-Khénifra',
  'Drâa-Tafilalet',
  'Guelmim-Oued Noun',
  'Laâyoune-Sakia El Hamra',
  'Dakhla-Oued Ed-Dahab',
];

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);
    final user = userAsync.valueOrNull;
    final locale = ref.watch(localeProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider).valueOrNull;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: user == null
          ? const Center(child: GreenSpinner())
          : ListView(
              padding: EdgeInsets.only(bottom: 32.h),
              children: [
                _ProfileHeader(user: user),
                SizedBox(height: 16.h),
                _SectionTitle(title: 'Paramètres'),
                SizedBox(height: 8.h),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF0288D1),
                      title: 'Langue',
                      subtitle: locale?.languageCode == 'ar'
                          ? 'العربية'
                          : 'Français',
                      trailing: _buildLangChip(locale?.languageCode),
                      onTap: () =>
                          ref.read(localeProvider.notifier).toggle(),
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: const Color(0xFF7B1FA2),
                      title: 'Mode sombre',
                      subtitle: isDark ? 'Activé' : 'Désactivé',
                      trailing: Switch(
                        value: isDark,
                        activeTrackColor: const Color(0xFF7B1FA2)
                            .withValues(alpha: 0.4),
                        activeThumbColor: const Color(0xFF7B1FA2),
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFFF57C00),
                      title: 'Wilaya',
                      subtitle: user.wilaya.isNotEmpty
                          ? user.wilaya
                          : 'Non définie',
                      onTap: () => _changeWilaya(context, ref, user),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFF00897B),
                      title: 'Notifications',
                      subtitle: 'Activées',
                      trailing: Switch(
                        value: true,
                        activeTrackColor: const Color(0xFF00897B)
                            .withValues(alpha: 0.4),
                        activeThumbColor: const Color(0xFF00897B),
                        onChanged: (_) {},
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFFD32F2F),
                      title: 'Mot de passe',
                      subtitle: 'Changer votre mot de passe',
                      onTap: () => _showPasswordSheet(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _SectionTitle(title: 'À propos'),
                SizedBox(height: 8.h),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.primary,
                      title: 'Version',
                      subtitle: '1.0.0',
                      trailing: Text(
                        'v1.0.0',
                        style: AppTextStyles.bodySmall(color: AppColors.grey400),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.star_outline_rounded,
                      iconColor: const Color(0xFFFFA000),
                      title: 'Noter l\'application',
                      subtitle: 'Sur le Play Store',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.share_outlined,
                      iconColor: const Color(0xFF0288D1),
                      title: 'Partager',
                      subtitle: 'Partager SoukConnect',
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _LogoutButton(ref: ref),
                ),
              ],
            ),
    );
  }

  Widget _buildLangChip(String? code) {
    final isAr = code == 'ar';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAr
            ? const Color(0xFF0288D1).withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  isAr
                      ? 'assets/flags/morocco.png'
                      : 'assets/flags/france.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            isAr ? 'العربية' : 'FR',
            style: AppTextStyles.labelSmall(
              color: isAr
                  ? const Color(0xFF0288D1)
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeWilaya(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Choisir une wilaya',
              style: AppTextStyles.titleMedium(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            height: 300.h,
            child: ListView(
              children: _wilayas
                  .map(
                    (w) => ListTile(
                      title: Text(w),
                      trailing: user.wilaya == w
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.of(ctx).pop(w),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );

    if (selected != null && selected != user.wilaya) {
      await supabase
          .from('profiles')
          .update({'wilaya': selected}).eq('id', user.id);
      ref.invalidate(authNotifierProvider);
    }
  }

  void _showPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const _PasswordSheet(),
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader({required this.user});
  final dynamic user;

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initial = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : '?';
    final isGrossiste = user.role.value == 'grossiste';
    final roleIcon = isGrossiste
        ? Icons.warehouse_rounded
        : Icons.storefront_rounded;
    final roleLabel = user.role.label;
    final memberSince =
        'Membre depuis ${_formatDate(user.createdAt)}';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // ── Avatar with animated ring ────────────────────────────
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, child) {
              return CustomPaint(
                painter: _RotatingRingPainter(
                  value: _ringCtrl.value,
                  color: AppColors.secondary.withValues(alpha: 0.6),
                ),
                child: child,
              );
            },
            child: CircleAvatar(
              radius: 36.w,
              backgroundColor: AppColors.white.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: AppTextStyles.headlineMedium(color: AppColors.white),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Name ─────────────────────────────────────────────────
          Text(
            user.fullName,
            style: AppTextStyles.titleLarge(color: AppColors.white),
          ),
          SizedBox(height: 8.h),

          // ── Role badge ───────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleIcon, size: 14.sp, color: AppColors.white),
                SizedBox(width: 6.w),
                Text(
                  roleLabel,
                  style: AppTextStyles.labelSmall(color: AppColors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // ── Phone ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_outlined,
                  size: 14.sp, color: AppColors.white.withValues(alpha: 0.8)),
              SizedBox(width: 6.w),
              Text(
                user.phone,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // ── Member since ─────────────────────────────────────────
          Text(
            memberSince,
            style: AppTextStyles.bodySmall(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _RotatingRingPainter extends CustomPainter {
  const _RotatingRingPainter({
    required this.value,
    required this.color,
  });

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 + 4;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      value * 2 * 3.14159,
      1.5 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RotatingRingPainter old) =>
      old.value != value;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        title,
        style: AppTextStyles.titleSmall(
          color: AppColors.grey500,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall(color: AppColors.grey500),
            )
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              size: 20.sp, color: AppColors.grey400),
      onTap: onTap,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmSignOut(context, ref),
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Se déconnecter'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      onConfirm: () {},
      type: DialogType.danger,
      confirmLabel: 'Se déconnecter',
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) context.go('/login');
    }
  }
}

class _PasswordSheet extends StatefulHookConsumerWidget {
  const _PasswordSheet();

  @override
  ConsumerState<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends ConsumerState<_PasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: EdgeInsets.all(20.w),
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: AppColors.error, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Changer le mot de passe',
                  style: AppTextStyles.titleLarge(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel',
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 12.h),
              Text(
                _error!,
                style: AppTextStyles.bodySmall(color: AppColors.error),
              ),
            ],
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const GreenSpinner(size: 22),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final current = _currentCtrl.text.trim();
    final newPw = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Tous les champs sont requis.');
      return;
    }
    if (newPw != confirm) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (newPw.length < 6) {
      setState(() => _error = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await supabase.auth.updateUser(UserAttributes(password: newPw));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Erreur: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
