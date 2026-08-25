import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

class JoinTripModal extends StatefulWidget {
  final Function(TripModel) onTripJoined;

  const JoinTripModal({super.key, required this.onTripJoined});

  static void show(BuildContext context, {required Function(TripModel) onTripJoined}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JoinTripModal(onTripJoined: onTripJoined),
    );
  }

  @override
  State<JoinTripModal> createState() => _JoinTripModalState();
}

class _JoinTripModalState extends State<JoinTripModal> {
  final BffClient _bff = ServiceLocator.instance.get<BffClient>();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Por favor, digite o código de convite');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = TripContext.instance.currentUser;

    try {
      final response = await _bff.post('/api/v1/trips/join', {
        'shareCode': code,
        'userId': currentUser?.id,
        'userEmail': currentUser?.email,
        'userName': currentUser?.name,
      });

      if (response is Map<String, dynamic> && response['success'] == true && response['data'] != null) {
        final trip = TripModel.fromJson(response['data']);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Você entrou na viagem "${trip.title}"!'),
              backgroundColor: MaceioColors.turquoiseDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        widget.onTripJoined(trip);
      } else {
        final msg = response is Map ? response['message'] : null;
        setState(() => _errorMessage = msg?.toString() ?? 'Código inválido ou viagem não encontrada');
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = msg.isNotEmpty ? msg : 'Erro ao conectar. Verifique o código digitado.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: MaceioColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MaceioColors.coralLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.confirmation_number_outlined, color: MaceioColors.coralAccent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar com Convite', style: MaceioTypography.titleLarge),
                      Text('Conecte-se à viagem criada por sua família', style: MaceioTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Instructions
            Text(
              'Insira o código de convite (ex: PARTIU-8942) que você recebeu pelo WhatsApp ou mensagem:',
              style: MaceioTypography.bodyMedium,
            ),
            const SizedBox(height: 14),

            // Code Input Field
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontFamily: 'monospace',
                color: MaceioColors.oceanDeep,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'EX: PARTIU-8942',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: MaceioColors.surfaceElevated,
                prefixIcon: const Icon(Icons.vpn_key, color: MaceioColors.turquoisePrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: MaceioColors.turquoisePrimary.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MaceioColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: MaceioColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: MaceioColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MaceioColors.turquoisePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  _isLoading ? 'Vinculando...' : 'Entrar na Viagem',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _handleJoin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
