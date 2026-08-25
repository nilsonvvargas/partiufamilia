import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/stay_model.dart';
import '../services/stay_service.dart';

class StayView extends StatefulWidget {
  const StayView({super.key});

  @override
  State<StayView> createState() => _StayViewState();
}

class _StayViewState extends State<StayView> {
  final StayService _service = StayService();
  late Future<StayModel?> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = _service.getStay();
    });
  }

  void _showEditStayModal({StayModel? currentStay}) {
    final isEditing = currentStay != null && currentStay.name.isNotEmpty;

    final nameController = TextEditingController(text: currentStay?.name ?? '');
    final addressController = TextEditingController(text: currentStay?.address ?? '');
    final neighborhoodController = TextEditingController(text: currentStay?.neighborhood ?? '');
    final checkInController = TextEditingController(text: currentStay?.checkIn ?? '14:00');
    final checkOutController = TextEditingController(text: currentStay?.checkOut ?? '11:00');
    final bookingCodeController = TextEditingController(text: currentStay?.bookingCode ?? '');
    final wifiNameController = TextEditingController(text: currentStay?.wifiNetwork ?? '');
    final wifiPasswordController = TextEditingController(text: currentStay?.wifiPassword ?? '');
    final hostContactController = TextEditingController(text: currentStay?.hostContact ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: MaceioColors.turquoisePrimary.withValues(alpha: 0.15),
                      child: Icon(
                        isEditing ? Icons.edit : Icons.hotel,
                        color: MaceioColors.turquoisePrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Editar Hospedagem' : 'Cadastrar Hospedagem',
                            style: MaceioTypography.titleLarge,
                          ),
                          Text(
                            isEditing
                                ? 'Atualize as informações da estadia da família'
                                : 'Adicione hotel, pousada, Airbnb e Wi-Fi',
                            style: MaceioTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Hotel / Pousada / Airbnb',
                    hintText: 'Ex: Hotel Vista Mar ou Airbnb Centro',
                    prefixIcon: const Icon(Icons.hotel, color: MaceioColors.turquoisePrimary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'Endereço',
                          hintText: 'Ex: Av. Beira Mar, 100',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: neighborhoodController,
                        decoration: InputDecoration(
                          labelText: 'Bairro',
                          hintText: 'Ex: Centro',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: checkInController,
                        decoration: InputDecoration(
                          labelText: 'Check-in',
                          hintText: '14:00',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: checkOutController,
                        decoration: InputDecoration(
                          labelText: 'Check-out',
                          hintText: '11:00',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: bookingCodeController,
                  decoration: InputDecoration(
                    labelText: 'Código / Nº da Reserva',
                    hintText: 'Ex: RES-2026-9988',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined, color: MaceioColors.turquoisePrimary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wifiNameController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Wi-Fi',
                          hintText: 'Ex: Rede_Hotel',
                          prefixIcon: const Icon(Icons.wifi, color: MaceioColors.turquoisePrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: wifiPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Senha do Wi-Fi',
                          hintText: 'Ex: senha123',
                          prefixIcon: const Icon(Icons.lock_outline, color: MaceioColors.turquoisePrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: hostContactController,
                  decoration: InputDecoration(
                    labelText: 'Contato da Recepção / Anfitrião',
                    hintText: 'Ex: (11) 99999-0000',
                    prefixIcon: const Icon(Icons.phone, color: MaceioColors.turquoisePrimary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: MaceioButton(
                    label: isEditing ? 'Salvar Alterações' : 'Cadastrar Hospedagem',
                    icon: Icons.save,
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      Navigator.pop(context);

                      await _service.updateStay(
                        name: name,
                        address: addressController.text.trim(),
                        neighborhood: neighborhoodController.text.trim(),
                        checkIn: checkInController.text.trim(),
                        checkOut: checkOutController.text.trim(),
                        bookingCode: bookingCodeController.text.trim(),
                        wifiNetwork: wifiNameController.text.trim(),
                        wifiPassword: wifiPasswordController.text.trim(),
                        hostContact: hostContactController.text.trim(),
                      );

                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripContext.instance.activeTrip;

    return Scaffold(
      backgroundColor: MaceioColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MaceioHeader(
              title: activeTrip != null ? 'Estadia • ${activeTrip.destination}' : 'Hospedagem & Estadia',
              subtitle: 'Sua base de apoio e conforto da família',
              badge: 'Acomodação',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),
            Expanded(
              child: FutureBuilder<StayModel?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary));
                  }

                  final stay = snapshot.data;
                  if (stay == null || stay.name.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: MaceioColors.surfaceElevated,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.hotel, size: 48, color: MaceioColors.turquoiseDark),
                            ),
                            const SizedBox(height: 16),
                            Text('Nenhuma hospedagem cadastrada', style: MaceioTypography.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              'Cadastre o hotel, pousada, endereço e senha do Wi-Fi da sua viagem para ${activeTrip?.destination ?? "seu destino"}.',
                              textAlign: TextAlign.center,
                              style: MaceioTypography.caption,
                            ),
                            const SizedBox(height: 20),
                            MaceioButton(
                              label: 'Cadastrar Hospedagem',
                              icon: Icons.add_business,
                              onPressed: () => _showEditStayModal(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Header Card
                      MaceioCard(
                        backgroundColor: MaceioColors.oceanDeep,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.hotel_class, color: MaceioColors.sunYellow, size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    stay.name,
                                    style: MaceioTypography.titleLarge.copyWith(color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                                  tooltip: 'Editar Estadia',
                                  onPressed: () => _showEditStayModal(currentStay: stay),
                                ),
                              ],
                            ),
                            if (stay.address.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  final activeTrip = TripContext.instance.activeTrip;
                                  final fullAddress = '${stay.address}, ${stay.neighborhood} - ${activeTrip?.destination ?? ""}';
                                  MapUtils.openGoogleMaps(fullAddress);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: MaceioColors.sunYellow),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        stay.neighborhood.isNotEmpty
                                            ? '${stay.address} - ${stay.neighborhood}'
                                            : stay.address,
                                        style: MaceioTypography.bodyMedium.copyWith(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.open_in_new, size: 14, color: Colors.white70),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stay.bookingCode.isNotEmpty
                                        ? 'Código: ${stay.bookingCode}'
                                        : 'Reserva Confirmada',
                                    style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Check-in: ${stay.checkIn} | Check-out: ${stay.checkOut}',
                                    style: MaceioTypography.caption.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Wi-Fi Card
                      if (stay.wifiNetwork.isNotEmpty || stay.wifiPassword.isNotEmpty) ...[
                        MaceioCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.wifi, color: MaceioColors.turquoisePrimary),
                                  const SizedBox(width: 8),
                                  Text('Wi-Fi da Acomodação', style: MaceioTypography.titleMedium),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (stay.wifiNetwork.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Rede:', style: MaceioTypography.caption),
                                        Text(stay.wifiNetwork, style: MaceioTypography.titleMedium.copyWith(fontSize: 15)),
                                      ],
                                    ),
                                  if (stay.wifiPassword.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Senha:', style: MaceioTypography.caption),
                                        Text(stay.wifiPassword, style: MaceioTypography.titleMedium.copyWith(fontSize: 15)),
                                      ],
                                    ),
                                  if (stay.wifiPassword.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.copy, color: MaceioColors.turquoisePrimary, size: 20),
                                      tooltip: 'Copiar Senha',
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: stay.wifiPassword));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Senha do Wi-Fi copiada!')),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Host Contact Card
                      if (stay.hostContact.isNotEmpty) ...[
                        MaceioCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MaceioColors.coralLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.support_agent, color: MaceioColors.coralAccent),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Contato da Recepção / Anfitrião', style: MaceioTypography.caption),
                                    Text(stay.hostContact, style: MaceioTypography.titleMedium),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Edit Button CTA
                      SizedBox(
                        width: double.infinity,
                        child: MaceioButton(
                          label: 'Editar Dados da Hospedagem',
                          icon: Icons.edit,
                          isSecondary: true,
                          onPressed: () => _showEditStayModal(currentStay: stay),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
