import 'package:flutter/material.dart';
import 'package:coopengageplus/service/certificate_service.dart';
import 'package:coopengageplus/constants/config/environment_config.dart';

class EnvironmentSelector extends StatefulWidget {
  const EnvironmentSelector({Key? key}) : super(key: key);

  @override
  State<EnvironmentSelector> createState() => _EnvironmentSelectorState();
}

class _EnvironmentSelectorState extends State<EnvironmentSelector> {
  String _currentEnvironment = EnvironmentConfig.DEFAULT_ENVIRONMENT;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentEnvironment();
  }

  Future<void> _loadCurrentEnvironment() async {
    try {
      String environment = await CertificateService.getCurrentEnvironment();
      setState(() {
        _currentEnvironment = environment;
      });
    } catch (e) {
      print('Error loading environment: $e');
    }
  }

  Future<void> _changeEnvironment(String newEnvironment) async {
    if (newEnvironment == _currentEnvironment) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await CertificateService.setEnvironment(newEnvironment);
      setState(() {
        _currentEnvironment = newEnvironment;
        _isLoading = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Environment changed to ${newEnvironment.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing environment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Environment Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Current Environment: ${_currentEnvironment.toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading 
                        ? null 
                        : () => _changeEnvironment(EnvironmentConfig.MTD),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentEnvironment == EnvironmentConfig.MTD
                          ? Colors.blue
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(EnvironmentConfig.MTD.toUpperCase()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading 
                        ? null 
                        : () => _changeEnvironment(EnvironmentConfig.RELID),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentEnvironment == EnvironmentConfig.RELID
                          ? Colors.blue
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(EnvironmentConfig.RELID.toUpperCase()),
                  ),
                ),
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Note: Changing environment will affect all network requests. '
              'The app will use the appropriate SSL certificate for the selected environment.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 