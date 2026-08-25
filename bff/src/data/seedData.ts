export interface TripItem {
  id: string;
  title: string;
  destination: string;
  state: string;
  startDate: string;
  endDate: string;
  tripDates: string;
  imageUrl: string;
  status: 'planned' | 'ongoing' | 'completed';
  tag: string;
  budget?: number;
  totalDays: number;
}

export interface ItineraryItem {
  id: string;
  tripId?: string;
  day: number;
  date: string;
  title: string;
  location: string;
  description: string;
  time: string;
  tideTime?: string;
  status: 'planned' | 'completed' | 'ongoing';
  tag: string;
  imageUrl: string;
}

export interface ExpenseItem {
  id: string;
  tripId?: string;
  title: string;
  amount: number;
  category: 'Passeio' | 'Alimentação' | 'Transporte' | 'Hospedagem' | 'Compras';
  paidBy: string;
  splitWith: string[];
  date: string;
}

export interface DiningItem {
  id: string;
  tripId?: string;
  name: string;
  cuisine: string;
  specialty: string;
  address: string;
  reservationTime: string;
  rating: number;
  status: 'reservado' | 'planejado' | 'visitado';
  notes: string;
}

export interface StayItem {
  id: string;
  tripId?: string;
  name: string;
  address: string;
  neighborhood: string;
  checkIn: string;
  checkOut: string;
  bookingCode: string;
  wifiNetwork: string;
  wifiPassword: string;
  rules: string[];
  amenities: string[];
  hostContact: string;
}

export interface PackingItem {
  id: string;
  tripId?: string;
  name: string;
  category: 'Praia & Sol' | 'Roupas' | 'Documentos' | 'Farmácia' | 'Eletrônicos';
  isPacked: boolean;
  quantity: number;
}

export interface ContactItem {
  id: string;
  tripId?: string;
  name: string;
  role: 'Guia de Lancha' | 'Bugueiro' | 'Transfer / Motorista' | 'Pousada / Anfitrião' | 'Companheiro de Viagem' | 'Emergência';
  phone: string;
  whatsapp: string;
  location: string;
  notes: string;
}

export const initialTrips: TripItem[] = [
  {
    id: 'trip-maceio',
    title: 'Paraíso das Águas & Piscinas Naturais 🏖️',
    destination: 'Maceió',
    state: 'Alagoas',
    startDate: '2026-09-10',
    endDate: '2026-09-15',
    tripDates: '10 Set - 15 Set 2026',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    status: 'ongoing',
    tag: 'Próxima Viagem',
    budget: 3500,
    totalDays: 5
  },
  {
    id: 'trip-gramado',
    title: 'Natal Luz & Rota dos Vinhos 🎄🍇',
    destination: 'Gramado e Canela',
    state: 'Rio Grande do Sul',
    startDate: '2026-12-05',
    endDate: '2026-12-10',
    tripDates: '05 Dez - 10 Dez 2026',
    imageUrl: 'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?auto=format&fit=crop&w=800&q=80',
    status: 'planned',
    tag: 'Planejada',
    budget: 4500,
    totalDays: 6
  },
  {
    id: 'trip-portodegalinhas',
    title: 'Mergulho & Jangadas de Corais 🐠🌊',
    destination: 'Porto de Galinhas',
    state: 'Pernambuco',
    startDate: '2027-02-12',
    endDate: '2027-02-17',
    tripDates: '12 Fev - 17 Fev 2027',
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
    status: 'planned',
    tag: 'Carnaval 2027',
    budget: 4000,
    totalDays: 6
  }
];

export const initialItineraries: ItineraryItem[] = [
  {
    id: 'it-1',
    tripId: 'trip-maceio',
    day: 1,
    date: '2026-09-10',
    title: 'Chegada em Maceió & Pôr do Sol na Ponta Verde',
    location: 'Ponta Verde & Pajuçara',
    description: 'Check-in na pousada, caminhada pela orla da Ponta Verde, visita ao totem "Eu Amo Maceió" e coco gelado no Lopana.',
    time: '14:00',
    status: 'planned',
    tag: 'Chegada / Orla',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'it-2',
    tripId: 'trip-maceio',
    day: 2,
    date: '2026-09-11',
    title: 'Piscinas Naturais de Pajuçara & Praia do Francês',
    location: 'Pajuçara & Marechal Deodoro',
    description: 'Passeio de jangada rústica até as piscinas naturais na maré baixa. À tarde, relaxar no beach club na Praia do Francês.',
    time: '08:30',
    tideTime: 'Maré baixa: 0.2m às 09:15',
    status: 'planned',
    tag: 'Piscinas Naturais',
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'it-3',
    tripId: 'trip-maceio',
    day: 3,
    date: '2026-09-12',
    title: 'Praia do Gunga, Falésias & Passeio de Buggy',
    location: 'Roteiro / Barra de São Miguel',
    description: 'Travessia de lancha saindo da Barra de São Miguel até a Praia do Gunga. Buggy até as falésias coloridas e banho na lagoa.',
    time: '08:00',
    status: 'planned',
    tag: 'Aventura & Buggy',
    imageUrl: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'it-4',
    tripId: 'trip-maceio',
    day: 4,
    date: '2026-09-13',
    title: 'Bate-Volta em São Miguel dos Milagres & Rota Ecológica',
    location: 'São Miguel dos Milagres',
    description: 'Águas cristalinas na Praia do Toque, Capela dos Milagres e almoço à beira-mar no Milagres do Toque Beach Club.',
    time: '07:00',
    tideTime: 'Maré baixa: 0.1m às 10:40',
    status: 'planned',
    tag: 'Caribe Brasileiro',
    imageUrl: 'https://images.unsplash.com/photo-1590523277543-a94d2e4eb00b?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'it-5',
    tripId: 'trip-maceio',
    day: 5,
    date: '2026-09-14',
    title: 'Galés de Maragogi & Caminho de Moisés',
    location: 'Maragogi & Barra Grande',
    description: 'Catamarã para as maiores galés de corais de Alagoas e visita ao banco de areia no mar (Caminho de Moisés).',
    time: '06:30',
    tideTime: 'Maré baixa: 0.0m às 11:20',
    status: 'planned',
    tag: 'Mergulho & Corais',
    imageUrl: 'https://images.unsplash.com/photo-1584824486509-112e4181ff6b?auto=format&fit=crop&w=800&q=80'
  }
];

export const initialExpenses: ExpenseItem[] = [
  {
    id: 'exp-1',
    tripId: 'trip-maceio',
    title: 'Passeio de Jangada Pajuçara (2 pessoas)',
    amount: 160.00,
    category: 'Passeio',
    paidBy: 'Nilson',
    splitWith: ['Nilson', 'Família'],
    date: '2026-09-11'
  },
  {
    id: 'exp-2',
    tripId: 'trip-maceio',
    title: 'Almoço Restaurante Bodega do Sertão',
    amount: 195.50,
    category: 'Alimentação',
    paidBy: 'Nilson',
    splitWith: ['Nilson', 'Família'],
    date: '2026-09-10'
  },
  {
    id: 'exp-3',
    tripId: 'trip-maceio',
    title: 'Buggy Falésias do Gunga',
    amount: 250.00,
    category: 'Passeio',
    paidBy: 'Nilson',
    splitWith: ['Nilson', 'Família'],
    date: '2026-09-12'
  },
  {
    id: 'exp-4',
    tripId: 'trip-maceio',
    title: 'Transfer Aeroporto -> Hotel Pajuçara',
    amount: 85.00,
    category: 'Transporte',
    paidBy: 'Nilson',
    splitWith: ['Nilson', 'Família'],
    date: '2026-09-10'
  },
  {
    id: 'exp-5',
    tripId: 'trip-maceio',
    title: 'Entrada Beach Club Milagres do Toque',
    amount: 180.00,
    category: 'Passeio',
    paidBy: 'Nilson',
    splitWith: ['Nilson', 'Família'],
    date: '2026-09-13'
  }
];

export const initialDining: DiningItem[] = [
  {
    id: 'din-1',
    tripId: 'trip-maceio',
    name: 'Bodega do Sertão',
    cuisine: 'Regional Nordestina / Alagoana',
    specialty: 'Carne de Sol na Nata, Baião de Dois e Cocada Cremosa',
    address: 'Av. Júlio Marques Luz, 405 - Jatiúca, Maceió',
    reservationTime: '10/09 às 20:00',
    rating: 4.9,
    status: 'reservado',
    notes: 'Restaurante famoso pelo bule gigante na entrada e buffet rústico impecável.'
  },
  {
    id: 'din-2',
    tripId: 'trip-maceio',
    name: 'Imperador dos Camarões',
    cuisine: 'Frutos do Mar',
    specialty: 'Chiclete de Camarão Tradicional (Famoso de Alagoas)',
    address: 'Av. Dr. Antônio Gouveia, 21 - Pajuçara, Maceió',
    reservationTime: '11/09 às 20:30',
    rating: 4.8,
    status: 'reservado',
    notes: 'Mesas de frente para a orla de Pajuçara com brisa do mar.'
  },
  {
    id: 'din-3',
    tripId: 'trip-maceio',
    name: 'Janchic Restaurante',
    cuisine: 'Contemporânea / Frutos do Mar',
    specialty: 'Polvo Grelhado com Risoto de Limão Siciliano',
    address: 'R. Eng. Mário de Gusmão, 988 - Ponta Verde, Maceió',
    reservationTime: '12/09 às 21:00',
    rating: 4.9,
    status: 'planejado',
    notes: 'Ambiente intimista excelente para jantar especial.'
  },
  {
    id: 'din-4',
    tripId: 'trip-maceio',
    name: 'Massarella Massas & Grelhados',
    cuisine: 'Italiana & Pizzas',
    specialty: 'Massa artesanal com Frutos do Mar',
    address: 'R. José Freire Moura, 255 - Ponta Verde, Maceió',
    reservationTime: '13/09 às 20:00',
    rating: 4.7,
    status: 'planejado',
    notes: 'Opção aconchegante para variar após os dias de praia.'
  }
];

export const initialStay: StayItem = {
  id: 'stay-maceio-1',
  tripId: 'trip-maceio',
  name: 'Pousada Areias de Ponta Verde Suítes',
  address: 'Rua Engenheiro Mario de Gusmão, 450',
  neighborhood: 'Ponta Verde, Maceió - AL',
  checkIn: '10/09/2026 a partir das 14:00',
  checkOut: '15/09/2026 até às 11:00',
  bookingCode: 'MCZ-2026-9874',
  wifiNetwork: 'AreiasPontaVerde_5G',
  wifiPassword: 'paraisodasaguas',
  rules: [
    'Café da manhã servido das 07:00 às 10:00 no piso térreo',
    'Toalhas de praia disponíveis na recepção mediante solicitação',
    'Silêncio após às 22:00 nas áreas comuns',
    'Check-out tardio sob consulta na véspera'
  ],
  amenities: [
    'Piscina no Rooftop com vista mar',
    'Ar Condicionado Split',
    'Frigobar abastecido',
    'Wi-Fi Ultra Rápido',
    'Secador de Cabelo',
    'Cofre Digital'
  ],
  hostContact: '+55 82 99876-5432 (Recepção 24h)'
};

export const initialPacking: PackingItem[] = [
  { id: 'pack-1', tripId: 'trip-maceio', name: 'Protetor Solar FPS 50+ & Protetor Labial', category: 'Praia & Sol', isPacked: true, quantity: 2 },
  { id: 'pack-2', tripId: 'trip-maceio', name: 'Óculos de Sol com Proteção UV', category: 'Praia & Sol', isPacked: true, quantity: 1 },
  { id: 'pack-3', tripId: 'trip-maceio', name: 'Sapatilha Aquática de Neoprene (para corais/maré baixa)', category: 'Praia & Sol', isPacked: false, quantity: 1 },
  { id: 'pack-4', tripId: 'trip-maceio', name: 'Bolsa / Capa Estanque Impermeável para Celular', category: 'Praia & Sol', isPacked: true, quantity: 2 },
  { id: 'pack-5', tripId: 'trip-maceio', name: 'Biquínis / Sungas / Shorts de banho', category: 'Roupas', isPacked: false, quantity: 4 },
  { id: 'pack-6', tripId: 'trip-maceio', name: 'Camisas UV manga longa para passeios de barco', category: 'Roupas', isPacked: true, quantity: 2 },
  { id: 'pack-7', tripId: 'trip-maceio', name: 'Roupas leves para jantar à noite', category: 'Roupas', isPacked: false, quantity: 5 },
  { id: 'pack-8', tripId: 'trip-maceio', name: 'Chinelo / Sandália confortável', category: 'Roupas', isPacked: true, quantity: 2 },
  { id: 'pack-9', tripId: 'trip-maceio', name: 'RG / CNH Original ou Digital', category: 'Documentos', isPacked: true, quantity: 1 },
  { id: 'pack-10', tripId: 'trip-maceio', name: 'Cartões de Crédito & Reserva da Pousada impressa/PDF', category: 'Documentos', isPacked: true, quantity: 1 },
  { id: 'pack-11', tripId: 'trip-maceio', name: 'Power Bank (Carregador portátil)', category: 'Eletrônicos', isPacked: true, quantity: 1 },
  { id: 'pack-12', tripId: 'trip-maceio', name: 'Adaptador de tomada e cabos USB-C / Lightning', category: 'Eletrônicos', isPacked: false, quantity: 2 },
  { id: 'pack-13', tripId: 'trip-maceio', name: 'Farmacinha (Dramin para barco, Dipirona, Antialérgico, Pós-sol)', category: 'Farmácia', isPacked: false, quantity: 1 }
];

export const initialContacts: ContactItem[] = [
  {
    id: 'ct-1',
    tripId: 'trip-maceio',
    name: 'Seu Cícero (Jangadeiro Pajuçara)',
    role: 'Guia de Lancha',
    phone: '+55 82 99123-4567',
    whatsapp: '5582991234567',
    location: 'Praia de Pajuçara, Jangada nº 14',
    notes: 'Jangadeiro credenciado, conhece as melhores piscinas naturais com peixinhos.'
  },
  {
    id: 'ct-2',
    tripId: 'trip-maceio',
    name: 'Beto Buggy (Falésias do Gunga)',
    role: 'Bugueiro',
    phone: '+55 82 99234-5678',
    whatsapp: '5582992345678',
    location: 'Praia do Gunga / Roteiro',
    notes: 'Passeio com emoção até as falésias e parada na Lagoa do Roteiro.'
  },
  {
    id: 'ct-3',
    tripId: 'trip-maceio',
    name: 'Carlos Transfer Alagoas',
    role: 'Transfer / Motorista',
    phone: '+55 82 99345-6789',
    whatsapp: '5582993456789',
    location: 'Aeroporto Zumbi dos Palmares / Hotéis',
    notes: 'Van executiva com ar condicionado para passeios em Maragogi e Milagres.'
  },
  {
    id: 'ct-4',
    tripId: 'trip-maceio',
    name: 'Recepção Pousada Areias',
    role: 'Pousada / Anfitrião',
    phone: '+55 82 99876-5432',
    whatsapp: '5582998765432',
    location: 'Ponta Verde, Maceió',
    notes: 'Atendimento 24h para suporte de quarto e agendamento de café da manhã.'
  },
  {
    id: 'ct-5',
    tripId: 'trip-maceio',
    name: 'SAMU / Bombeiros Maceió (Salva-Vidas)',
    role: 'Emergência',
    phone: '192 / 193',
    whatsapp: '5582988880000',
    location: 'Maceió - AL',
    notes: 'Posto de Salva Vidas na Ponta Verde e Pajuçara.'
  }
];
