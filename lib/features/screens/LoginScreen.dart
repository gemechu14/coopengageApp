import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/features/screens/login_notifier.dart';
import 'package:coopengageplus/shared/widgets/AlertDialog/dialog_helper.dart';
import 'package:coopengageplus/shared/widgets/app_button.dart';
import 'package:coopengageplus/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _accent = Color(0xFF1565C0);
const _muted = Color(0xFF78909C);
const _bgColor = Color(0xFFF1F5F9);

class Loginscreen extends ConsumerStatefulWidget {
  const Loginscreen({super.key});

  @override
  ConsumerState<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends ConsumerState<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(loginNotifierProvider.notifier).login(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isWide = width >= 600;
    final verticalPadding = height < 700 ? 16.0 : 24.0;

    _listenForSideEffects();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? width * 0.2 : 24,
                vertical: verticalPadding,
            ),
            child: _LoginCard(
              formKey: _formKey,
              usernameCtrl: _usernameCtrl,
              passwordCtrl: _passwordCtrl,
              state: state,
              onTogglePassword: ref
                  .read(loginNotifierProvider.notifier)
                  .togglePasswordVisibility,
              onLogin: _onLogin,
            ),
          ),
        ),
      ),
    );
  }

  void _listenForSideEffects() {
    ref.listen<LoginScreenState>(loginNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        DialogHelper.show(
          context,
          title: 'Coop Engage+',
          message: next.errorMessage!,
          type: DialogType.error,
        );
        ref.read(loginNotifierProvider.notifier).clearError();
      }

      if (next.shouldNavigate && !(prev?.shouldNavigate ?? false)) {
        ref.read(loginNotifierProvider.notifier).clearNavigation();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Login card (white card shell matching company design)
// ---------------------------------------------------------------------------

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.state,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final LoginScreenState state;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    // Keep spacing proportional on short screens, but don't shrink too aggressively.
    final double scale = (h / 800).clamp(0.75, 1.0);

    final double topGap = (84 * scale).clamp(56.0, 84.0);
    final titleGap = 4.0; // keep small and consistent
    final double betweenSubtitleAndUsername =
        (28 * scale).clamp(20.0, 28.0);
    final double gap8 = (8 * scale).clamp(6.0, 8.0);
    final double gap18 = (18 * scale).clamp(14.0, 18.0);
    final double gap24 = (24 * scale).clamp(18.0, 24.0);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Center(
          //   child: Image.asset(
          //     'assets/coop_engage.png',
          //     width: 180,
          //     height: 80,
          //     fit: BoxFit.contain,
          //   ),
          // ),
          SizedBox(height: topGap),
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey.shade900,
            ),
          ),
          SizedBox(height: titleGap),
          Text(
            'Sign in to continue',
            style: TextStyle(fontSize: 13, color: _muted, height: 1.3),
          ),
          SizedBox(height: betweenSubtitleAndUsername),

          // -- Username ---------------------------------------------------
          _FieldLabel(icon: Icons.person_outline, label: 'Username'),
          SizedBox(height: gap8),
          AppTextField(
            controller: usernameCtrl,
            hintText: 'Enter your username',
            enabled: !state.isLoading,
            prefixIcon: Icon(Icons.badge_outlined, color: _muted, size: 20),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Username cannot be empty' : null,
          ),
          SizedBox(height: gap18),

          // -- Password ---------------------------------------------------
          _FieldLabel(icon: Icons.lock_outline, label: 'Password'),
          SizedBox(height: gap8),
          AppTextField(
            controller: passwordCtrl,
            hintText: 'Enter your password',
            enabled: !state.isLoading,
            obscureText: state.hidePassword,
            prefixIcon: Icon(Icons.key_outlined, color: _muted, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                state.hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: _muted,
              ),
              splashRadius: 18,
              onPressed: state.isLoading ? null : onTogglePassword,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password cannot be empty' : null,
          ),
          SizedBox(height: gap24),

          // -- Login button -----------------------------------------------
          AppButton(
            label: 'Sign In',
            isLoading: state.isLoading,
            icon: Icons.login_rounded,
            onPressed: onLogin,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small label row (icon + text) above each field
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.blueGrey.shade900,
          ),
        ),
      ],
    );
  }
}
