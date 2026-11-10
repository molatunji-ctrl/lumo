import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../firebase_options.dart';
import '../../services/account_role_service.dart';
import '../../widgets/app_bottom_navigation.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Map<String, String> _defaultCopy = <String, String>{
    'account_title': 'Your account',
    'create_title': 'Create your account',
    'sign_in_title': 'Welcome back',
    'create_subtitle':
        'Sign up to save your favourite local shops and products.',
    'sign_in_subtitle': 'Sign in to pick up where you left off.',
    'full_name': 'Full name',
    'enter_name': 'Enter your name',
    'email': 'Email address',
    'invalid_email': 'Enter a valid email address',
    'password': 'Password',
    'enter_password': 'Enter your password',
    'password_minimum': 'Use at least 6 characters',
    'confirm_password': 'Confirm password',
    'passwords_mismatch': 'Passwords do not match',
    'forgot_password': 'Forgot password?',
    'show_password': 'Show password',
    'hide_password': 'Hide password',
    'continue_with': 'or continue with',
    'google': 'Google',
    'use_phone': 'Use your phone number instead',
    'already_account': 'Already have an account?',
    'new_to_keepr': 'New to Keepr?',
    'create_account': 'Create account',
    'sign_in': 'Sign in',
    'terms': 'By continuing, you agree to Keepr’s Terms of Service and Privacy Policy.',
    'back_sign_in': 'Back to sign in',
    'verify_phone': 'Verify your phone',
    'phone_sign_in': 'Sign in with phone',
    'verify_phone_subtitle': 'Enter the verification code sent to your number.',
    'phone_subtitle': 'We’ll text you a one-time code to verify your number.',
    'phone_number': 'Phone number',
    'search_country': 'Search country',
    'invalid_phone': 'Enter a valid phone number',
    'verification_code': '6-digit verification code',
    'enter_code': 'Enter the 6-digit code',
    'verify_and_sign_in': 'Verify and sign in',
    'send_code': 'Send verification code',
    'resend_code': 'Resend code',
    'resend_countdown': 'Resend code in {seconds}',
    'signed_in': 'You’re signed in',
    'welcome': 'Welcome to Keepr, {name}.',
    'signed_in_with': 'Signed in with',
    'sign_out': 'Sign out',
    'member': 'Keepr member',
    'email_provider': 'Email and password',
    'phone_provider': 'Phone',
    'password_reset_sent': 'Password reset email sent.',
    'error_email_in_use':
        'An account already exists for this email. Try signing in.',
    'error_invalid_email': 'That email address is not valid.',
    'error_credentials': 'The email or password is incorrect.',
    'error_weak_password':
        'Choose a stronger password with at least 6 characters.',
    'error_user_disabled': 'This account has been disabled. Contact support.',
    'error_too_many_requests':
        'Too many attempts. Please wait a while and try again.',
    'error_operation_not_allowed':
        'This sign-in method is not enabled in Firebase Authentication.',
    'error_network':
        'Could not connect. Check your internet connection and try again.',
    'error_invalid_phone':
        'Enter a valid phone number in international format.',
    'error_captcha': 'Phone verification could not complete its reCAPTCHA check. Reload the page and try again.',
    'error_app_credential': 'Firebase could not verify this app. Check the authorized domain and reCAPTCHA configuration.',
    'error_domain': 'This domain is not authorized for Firebase Authentication. Add localhost under Authentication settings.',
    'error_storage': 'Phone verification requires browser storage. Enable cookies/site data and try again.',
    'error_invalid_code': 'That verification code is incorrect.',
    'error_expired_code': 'That code has expired. Request a new one.',
    'error_quota':
        'SMS verification is temporarily unavailable. Try again later.',
    'error_generic': 'Firebase authentication failed ({code}). Check the browser console for details.',
    'error_generic_message': '{message} (Firebase error: {code})',
    'error_request_code_first': 'Request a verification code first.',
    'error_request_code_wait': 'Please wait before requesting another code.',
    'error_enter_email_first': 'Enter your email address first.',
    'error_enter_code': 'Enter the 6-digit code.',
    'error_google_unsupported':
        'Google sign-in is not supported on this platform.',
    'error_google_token': 'Google did not return an ID token. Check the Google OAuth configuration in Firebase.',
    'error_google_configuration': 'Google sign-in is not configured for this app. Check the OAuth client and SHA fingerprints in Firebase.',
    'error_google': 'Google sign-in failed. Please try again.',
    'error_google_sign_out': 'Could not complete Google sign-out.',
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  bool _isCreatingAccount = false;
  bool _isPhoneFlow = false;
  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _verificationId;
  Future<String?>? _accountRoleCheck;
  String? _accountRoleCheckUid;
  String _phoneNumberE164 = '+234';
  Map<String, String> _copy = _defaultCopy;
  int? _resendToken;
  int _resendSecondsRemaining = 0;
  Timer? _resendTimer;

  String _text(String key, [Map<String, String> replacements = const {}]) {
    String value = _copy[key] ?? _defaultCopy[key] ?? key;
    for (final MapEntry<String, String> entry in replacements.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadRemoteCopy());
  }

  Future<void> _loadRemoteCopy() async {
    try {
      await _remoteConfig.setDefaults(_defaultCopy);
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
      final Map<String, String> remoteCopy = <String, String>{
        for (final String key in _defaultCopy.keys)
          if (_remoteConfig.getString(key).isNotEmpty)
            key: _remoteConfig.getString(key),
      };
      if (!mounted) return;
      setState(() {
        _copy = <String, String>{..._defaultCopy, ...remoteCopy};
      });
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Could not load account copy from Firebase Remote Config: '
        '${error.code}: ${error.message}\n$stackTrace',
      );
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final Color border = isDark
        ? AppColors.darkCardBorder
        : AppColors.lightCardBorder;
    final Color surface = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(_text('account_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRouter.home),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          initialData: _auth.currentUser,
          builder: (context, snapshot) {
            final User? user = snapshot.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    color: surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: user == null
                          ? _isPhoneFlow
                                ? _buildPhoneForm(foreground, secondary)
                                : _buildEmailForm(foreground, secondary, border)
                          : _buildSignedIn(user, foreground, secondary, border),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRouter.search);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRouter.nearby);
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRouter.favourites);
          }
        },
      ),
    );
  }

  Widget _buildEmailForm(Color foreground, Color secondary, Color border) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldFill = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrandMark(),
          const SizedBox(height: 24),
          Text(
            _text(_isCreatingAccount ? 'create_title' : 'sign_in_title'),
            style: TextStyle(
              color: foreground,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isCreatingAccount
                ? _text('create_subtitle')
                : _text('sign_in_subtitle'),
            style: TextStyle(color: secondary, height: 1.45),
          ),
          const SizedBox(height: 24),
          if (_isCreatingAccount) ...[
            _buildTextField(
              controller: _nameController,
              label: _text('full_name'),
              icon: Icons.person_outline,
              foreground: foreground,
              fillColor: fieldFill,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (_isCreatingAccount &&
                    (value == null || value.trim().isEmpty)) {
                  return _text('enter_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            label: _text('email'),
            icon: Icons.mail_outline,
            foreground: foreground,
            fillColor: fieldFill,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final String email = value?.trim() ?? '';
              if (email.isEmpty || !email.contains('@')) {
                return _text('invalid_email');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: _text('password'),
            icon: Icons.lock_outline,
            foreground: foreground,
            fillColor: fieldFill,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              tooltip: _text(
                _obscurePassword ? 'show_password' : 'hide_password',
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _text('enter_password');
              }
              if (_isCreatingAccount && value.length < 6) {
                return _text('password_minimum');
              }
              return null;
            },
          ),
          if (_isCreatingAccount) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: _text('confirm_password'),
              icon: Icons.lock_outline,
              foreground: foreground,
              fillColor: fieldFill,
              obscureText: true,
              validator: (value) {
                if (_isCreatingAccount && value != _passwordController.text) {
                  return _text('passwords_mismatch');
                }
                return null;
              },
            ),
          ],
          if (!_isCreatingAccount)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _sendPasswordReset,
                child: Text(_text('forgot_password')),
              ),
            )
          else
            const SizedBox(height: 20),
          if (_errorMessage != null) ...[
            _buildErrorMessage(_errorMessage!),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isLoading ? null : _submitEmailForm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _text(_isCreatingAccount ? 'create_account' : 'sign_in'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _text('continue_with'),
                  style: TextStyle(color: secondary),
                ),
              ),
              Expanded(child: Divider(color: border)),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: Text(_text('google')),
            style: OutlinedButton.styleFrom(
              foregroundColor: foreground,
              side: BorderSide(color: border),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isLoading ? null : _showPhoneSignIn,
            icon: const Icon(Icons.sms_outlined, size: 18),
            label: Text(_text('use_phone')),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isCreatingAccount
                    ? _text('already_account')
                    : _text('new_to_keepr'),
                style: TextStyle(color: secondary),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() {
                        _isCreatingAccount = !_isCreatingAccount;
                        _errorMessage = null;
                      }),
                child: Text(
                  _text(_isCreatingAccount ? 'sign_in' : 'create_account'),
                ),
              ),
            ],
          ),
          Text(
            _text('terms'),
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(Color foreground, Color secondary) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldFill = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => setState(() {
                      _isPhoneFlow = false;
                      _isCodeSent = false;
                      _resendSecondsRemaining = 0;
                      _resendTimer?.cancel();
                      _errorMessage = null;
                    }),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(_text('back_sign_in')),
            ),
          ),
          _buildBrandMark(),
          const SizedBox(height: 24),
          Text(
            _text(_isCodeSent ? 'verify_phone' : 'phone_sign_in'),
            style: TextStyle(
              color: foreground,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isCodeSent
                ? _text('verify_phone_subtitle')
                : _text('phone_subtitle'),
            style: TextStyle(color: secondary, height: 1.45),
          ),
          const SizedBox(height: 24),
          if (!_isCodeSent)
            IntlPhoneField(
              controller: _phoneController,
              initialCountryCode: 'NG',
              showCountryFlag: true,
              pickerDialogStyle: PickerDialogStyle(
                searchFieldInputDecoration: InputDecoration(
                  labelText: _text('search_country'),
                ),
              ),
              invalidNumberMessage: _text('invalid_phone'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(color: foreground),
              dropdownTextStyle: TextStyle(color: foreground),
              onChanged: (PhoneNumber number) {
                _phoneNumberE164 = number.completeNumber;
              },
              onCountryChanged: (Country country) {
                final String nationalNumber = _phoneController.text.replaceAll(
                  RegExp(r'\D'),
                  '',
                );
                _phoneNumberE164 = '+${country.fullCountryCode}$nationalNumber';
              },
              decoration: InputDecoration(
                labelText: _text('phone_number'),
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true,
                fillColor: fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.orange,
                    width: 1.5,
                  ),
                ),
              ),
            )
          else
            _buildTextField(
              controller: _smsCodeController,
              label: _text('verification_code'),
              icon: Icons.password_outlined,
              foreground: foreground,
              fillColor: fieldFill,
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) {
                if (value == null || value.trim().length != 6) {
                  return _text('enter_code');
                }
                return null;
              },
            ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(_errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isLoading
                  ? null
                  : _isCodeSent
                  ? _verifyPhoneCode
                  : _sendPhoneCode,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _text(_isCodeSent ? 'verify_and_sign_in' : 'send_code'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (_isCodeSent) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading || _resendSecondsRemaining > 0
                  ? null
                  : _resendPhoneCode,
              child: Text(
                _resendSecondsRemaining > 0
                    ? _text('resend_countdown', <String, String>{
                        'seconds': _formatCountdown(_resendSecondsRemaining),
                      })
                    : _text('resend_code'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignedIn(
    User user,
    Color foreground,
    Color secondary,
    Color border,
  ) {
    final String displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email ?? user.phoneNumber ?? _text('member');
    if (_accountRoleCheckUid != user.uid) {
      _accountRoleCheckUid = user.uid;
      _accountRoleCheck = const AccountRoleService().roleFor(
        user,
        forceRefresh: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBrandMark(),
        const SizedBox(height: 24),
        Text(
          _text('signed_in'),
          style: TextStyle(
            color: foreground,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _text('welcome', <String, String>{'name': displayName}),
          style: TextStyle(color: secondary),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(_errorMessage!),
        ],
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.email != null)
                _accountDetail(_text('email'), user.email!),
              if (user.phoneNumber != null)
                _accountDetail(_text('phone_number'), user.phoneNumber!),
              _accountDetail(
                _text('signed_in_with'),
                user.providerData
                    .map((provider) {
                      switch (provider.providerId) {
                        case 'google.com':
                          return _text('google');
                        case 'phone':
                          return _text('phone_provider');
                        case 'password':
                          return _text('email_provider');
                        default:
                          return provider.providerId;
                      }
                    })
                    .toSet()
                    .join(', '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<String?>(
          future: _accountRoleCheck,
          builder:
              (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Could not verify account permissions: ${snapshot.error}',
                      style: TextStyle(color: AppColors.error),
                    ),
                  );
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final String role = snapshot.data ?? 'shopper';
                final bool isSeller = role == sellerRole;
                final bool isAdmin = role == adminRole;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _accountDetail(
                        'Account type',
                        isAdmin
                            ? 'Administrator'
                            : isSeller
                            ? 'Seller'
                            : 'Shopper',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isSeller)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRouter.sellerProducts,
                        ),
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Manage my products'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: foreground,
                          side: BorderSide(color: border),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      )
                    else if (!isAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Seller tools are available to approved sellers. '
                          'Seller applications are not available in the app yet.',
                          style: TextStyle(color: secondary, height: 1.4),
                        ),
                      ),
                    if (isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.adminDashboard,
                          ),
                          icon: const Icon(
                            Icons.admin_panel_settings_outlined,
                          ),
                          label: const Text('Admin dashboard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: foreground,
                            side: BorderSide(color: border),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _isLoading ? null : _signOut,
          style: OutlinedButton.styleFrom(
            foregroundColor: foreground,
            side: BorderSide(color: border),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_text('sign_out')),
        ),
      ],
    );
  }

  Widget _accountDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.lightTextMuted),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBrandMark() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.storefront_rounded,
          color: AppColors.orange,
          size: 27,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color foreground,
    required Color fillColor,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    int? maxLength,
    String? prefixText,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(color: foreground),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        counterText: maxLength == null ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
        errorMaxLines: 2,
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEmailForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isCreatingAccount) {
        final UserCredential credential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        await credential.user?.updateDisplayName(_nameController.text.trim());
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      _showError(_friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = _text('error_enter_email_first'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_text('password_reset_sent'))));
      }
    } on FirebaseAuthException catch (error) {
      _showError(_friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      setState(() {
        _errorMessage = _text('error_google_unsupported');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(
          clientId:
              defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS
              ? DefaultFirebaseOptions.ios.iosClientId
              : null,
        );
        final GoogleSignInAccount googleUser = await googleSignIn
            .authenticate();
        final String? idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          _showError(_text('error_google_token'));
          return;
        }
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );
        await _auth.signInWithCredential(credential);
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } on GoogleSignInException catch (error) {
      if (error.code != GoogleSignInExceptionCode.canceled) {
        _showError(
          error.code == GoogleSignInExceptionCode.clientConfigurationError ||
                  error.code ==
                      GoogleSignInExceptionCode.providerConfigurationError
              ? _text('error_google_configuration')
              : error.description ?? _text('error_google'),
        );
      }
    } on FirebaseAuthException catch (error) {
      _showError(_friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPhoneSignIn() {
    setState(() {
      _isPhoneFlow = true;
      _isCodeSent = false;
      _errorMessage = null;
      _smsCodeController.clear();
    });
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsRemaining = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _resendSecondsRemaining = 0);
      } else {
        setState(() => _resendSecondsRemaining--);
      }
    });
  }

  String _formatCountdown(int seconds) {
    final String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final String remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _sendPhoneCode() async {
    if (!_phoneFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _requestPhoneCode(_phoneNumberE164);
  }

  Future<void> _resendPhoneCode() async {
    if (_resendSecondsRemaining > 0) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _requestPhoneCode(
      _phoneNumberE164,
      forceResendingToken: _resendToken,
    );
  }

  Future<void> _requestPhoneCode(
    String phoneNumber, {
    int? forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } on FirebaseAuthException catch (error) {
            _showError(_friendlyAuthError(error));
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          _showError(_friendlyAuthError(error));
          if (mounted) setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isCodeSent = true;
            _isLoading = false;
            _errorMessage = null;
          });
          _startResendCountdown();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          if (mounted) setState(() => _isLoading = false);
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (error) {
      _showError(_friendlyAuthError(error));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyPhoneCode() async {
    if (_verificationId == null) {
      setState(() => _errorMessage = _text('error_request_code_first'));
      return;
    }
    final String code = _smsCodeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = _text('error_enter_code'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      _showError(_friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final bool signedInWithGoogle =
        _auth.currentUser?.providerData.any(
          (provider) => provider.providerId == 'google.com',
        ) ??
        false;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (signedInWithGoogle) {
        await GoogleSignIn.instance.initialize();
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      _showError(_friendlyAuthError(error));
    } on GoogleSignInException catch (error) {
      if (error.code != GoogleSignInExceptionCode.canceled) {
        _showError(error.description ?? _text('error_google_sign_out'));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return _text('error_email_in_use');
      case 'invalid-email':
        return _text('error_invalid_email');
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return _text('error_credentials');
      case 'weak-password':
        return _text('error_weak_password');
      case 'user-disabled':
        return _text('error_user_disabled');
      case 'too-many-requests':
        return _text('error_too_many_requests');
      case 'operation-not-allowed':
        return _text('error_operation_not_allowed');
      case 'network-request-failed':
        return _text('error_network');
      case 'invalid-phone-number':
        return _text('error_invalid_phone');
      case 'captcha-check-failed':
        return _text('error_captcha');
      case 'missing-app-credential':
      case 'invalid-app-credential':
        return _text('error_app_credential');
      case 'app-not-authorized':
        return _text('error_domain');
      case 'web-storage-unsupported':
        return _text('error_storage');
      case 'invalid-verification-code':
        return _text('error_invalid_code');
      case 'session-expired':
        return _text('error_expired_code');
      case 'quota-exceeded':
        return _text('error_quota');
      default:
        final String? message = error.message?.trim();
        if (message != null &&
            message.isNotEmpty &&
            message.toLowerCase() != 'error') {
          return _text('error_generic_message', <String, String>{
            'message': message,
            'code': error.code,
          });
        }
        return _text('error_generic', <String, String>{'code': error.code});
    }
  }
}
