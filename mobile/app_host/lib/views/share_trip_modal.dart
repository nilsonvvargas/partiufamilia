import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

class ShareTripModal extends StatelessWidget {
  final TripModel trip;

  const ShareTripModal({super.key, required this.trip});

  static void show(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareTripModal(trip: trip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = trip.shareCode.isNotEmpty ? trip.shareCode : 'PARTIU-${trip.id.hashCode.abs().toString().substring(0, 4)}';
    final host = kIsWeb ? Uri.base.host : '192.168.15.49';
    final port = kIsWeb && Uri.base.port != 0 && Uri.base.port != 80 && Uri.base.port != 443 ? ':${Uri.base.port}' : ':8080';
    final appUrl = 'http://$host$port';

    final whatsappMessage = '''🌴 *Família Partiu! ✈️*
Você foi convidado(a) para participar da nossa viagem para *${trip.destination}* (${trip.tripDates})!

🎟️ *Código de Convite da Família:*
👉 *`$code`*

📱 Acesse o app no link abaixo e use o código para acompanhar o roteiro, hospedagem, passeios e gastos da nossa família:
$appUrl''';

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
            // Handle Bar
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
                    color: MaceioColors.oceanLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.share_location, color: MaceioColors.turquoisePrimary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compartilhar Viagem', style: MaceioTypography.titleLarge),
                      Text(
                        'Convide a família para acessar ${trip.destination}',
                        style: MaceioTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card com Código de Convite em Destaque
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MaceioColors.turquoisePrimary, MaceioColors.oceanDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: MaceioColors.turquoisePrimary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vpn_key_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'CÓDIGO DE CONVITE DA FAMÍLIA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      ShareUtils.copyToClipboard(
                        context,
                        code,
                        feedbackMessage: 'Código "$code" copiado!',
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy, size: 14, color: MaceioColors.oceanDeep),
                          const SizedBox(width: 6),
                          Text(
                            'Copiar Código',
                            style: TextStyle(
                              color: MaceioColors.oceanDeep,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Botão do WhatsApp (Verde Oficial)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.chat, color: Colors.white, size: 22),
                label: const Text(
                  'Compartilhar no WhatsApp 💬',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  ShareUtils.openWhatsApp(whatsappMessage);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Botão de Copiar Mensagem Completa
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.content_copy, size: 18, color: MaceioColors.turquoiseDark),
                label: const Text(
                  'Copiar Texto do Convite',
                  style: TextStyle(color: MaceioColors.turquoiseDark, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  ShareUtils.copyToClipboard(
                    context,
                    whatsappMessage,
                    feedbackMessage: 'Texto do convite copiado!',
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Explicação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MaceioColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: MaceioColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quando os familiares entrarem com este código, a viagem aparecerá automaticamente na conta deles.',
                      style: MaceioTypography.caption.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
