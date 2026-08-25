import { Router, Request, Response } from 'express';
import {
  initialTrips,
  TripItem,
  initialItineraries,
  initialExpenses,
  initialDining,
  initialStay,
  initialPacking,
  initialContacts
} from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const tripsRouter = Router();

export interface TripMember {
  id: string;
  tripId: string;
  userId?: string;
  userEmail?: string;
  userName?: string;
  role: 'organizer' | 'member';
  joinedAt: string;
}

function generateShareCode(destination: string): string {
  const cleanDest = destination.trim().split(' ')[0].toUpperCase().replace(/[^A-Z]/g, '');
  const prefix = cleanDest.length >= 3 ? cleanDest.substring(0, 4) : 'PARTIU';
  const randomNum = Math.floor(1000 + Math.random() * 9000);
  return `${prefix}-${randomNum}`;
}

let trips: TripItem[] = [];
let tripMembers: TripMember[] = [];

// GET all trips (filtered by user if userId/userEmail provided for multi-tenant isolation)
tripsRouter.get('/', async (req: Request, res: Response) => {
  const { userId, userEmail } = req.query;

  try {
    let query = supabase.from('trips').select('*').order('start_date', { ascending: true });

    // If userId/userEmail is provided, filter for owner or member
    if (userId || userEmail) {
      // 1. Get tripIds from trip_members
      let memberTripIds: string[] = [];
      try {
        let memQuery = supabase.from('trip_members').select('trip_id');
        if (userId) memQuery = memQuery.eq('user_id', String(userId));
        else if (userEmail) memQuery = memQuery.eq('user_email', String(userEmail));
        const { data: memData } = await memQuery;
        if (memData) {
          memberTripIds = memData.map((m: any) => m.trip_id);
        }
      } catch (me) {
        console.warn('trip_members fetch error:', (me as Error).message);
      }

      // Query trips owned by user OR in memberTripIds
      const { data, error } = await query;
      if (!error && data) {
        const filtered = data.filter((t: any) => {
          const isOwner = userId ? t.owner_id === String(userId) : false;
          const isMember = memberTripIds.includes(t.id);
          // If no owner_id is set on existing trips, allow viewing
          const isPublicOrLegacy = !t.owner_id;
          return isOwner || isMember || isPublicOrLegacy;
        });

        const mapped = filtered.map((t: any) => ({
          id: t.id,
          ownerId: t.owner_id ?? t.ownerId,
          shareCode: t.share_code ?? t.shareCode,
          title: t.title,
          destination: t.destination,
          state: t.state,
          startDate: t.start_date ?? t.startDate,
          endDate: t.end_date ?? t.endDate,
          tripDates: t.trip_dates ?? t.tripDates,
          imageUrl: t.image_url ?? t.imageUrl,
          status: t.status,
          tag: t.tag,
          budget: t.budget,
          totalDays: t.total_days ?? t.totalDays
        }));
        return res.json({ success: true, data: mapped, source: 'supabase' });
      }
    } else {
      const { data, error } = await query;
      if (!error && data) {
        const mapped = data.map((t: any) => ({
          id: t.id,
          ownerId: t.owner_id ?? t.ownerId,
          shareCode: t.share_code ?? t.shareCode,
          title: t.title,
          destination: t.destination,
          state: t.state,
          startDate: t.start_date ?? t.startDate,
          endDate: t.end_date ?? t.endDate,
          tripDates: t.trip_dates ?? t.tripDates,
          imageUrl: t.image_url ?? t.imageUrl,
          status: t.status,
          tag: t.tag,
          budget: t.budget,
          totalDays: t.total_days ?? t.totalDays
        }));
        return res.json({ success: true, data: mapped, source: 'supabase' });
      }
    }
  } catch (e) {
    console.warn('Supabase trips query failed, using local store:', (e as Error).message);
  }

  // Memory store fallback
  let filteredTrips = trips;
  if (userId || userEmail) {
    const memberTripIds = tripMembers
      .filter(m => (userId && m.userId === userId) || (userEmail && m.userEmail === userEmail))
      .map(m => m.tripId);

    filteredTrips = trips.filter(t => {
      const isOwner = userId ? (t as any).ownerId === userId : false;
      const isMember = memberTripIds.includes(t.id);
      const isLegacy = !(t as any).ownerId;
      return isOwner || isMember || isLegacy;
    });
  }

  return res.json({ success: true, data: filteredTrips, source: 'memory' });
});

// POST join trip using share code (Convite da Família)
tripsRouter.post('/join', async (req: Request, res: Response) => {
  const { shareCode, userId, userEmail, userName } = req.body;

  if (!shareCode || typeof shareCode !== 'string') {
    return res.status(400).json({ success: false, message: 'Código de convite é obrigatório' });
  }

  const cleanCode = shareCode.trim().toUpperCase();

  try {
    // 1. Find trip by shareCode in Supabase
    const { data: tripRow, error } = await supabase
      .from('trips')
      .select('*')
      .ilike('share_code', cleanCode)
      .maybeSingle();

    if (!error && tripRow) {
      const trip = {
        id: tripRow.id,
        ownerId: tripRow.owner_id ?? tripRow.ownerId,
        shareCode: tripRow.share_code ?? tripRow.shareCode,
        title: tripRow.title,
        destination: tripRow.destination,
        state: tripRow.state,
        startDate: tripRow.start_date ?? tripRow.startDate,
        endDate: tripRow.end_date ?? tripRow.endDate,
        tripDates: tripRow.trip_dates ?? tripRow.tripDates,
        imageUrl: tripRow.image_url ?? tripRow.imageUrl,
        status: tripRow.status,
        tag: tripRow.tag,
        budget: tripRow.budget,
        totalDays: tripRow.total_days ?? tripRow.totalDays
      };

      // Add to trip_members if user info is present
      if (userId || userEmail) {
        try {
          await supabase.from('trip_members').upsert([{
            id: `member-${tripRow.id}-${userId || userEmail}`,
            trip_id: tripRow.id,
            user_id: userId || null,
            user_email: userEmail || null,
            user_name: userName || 'Familiar',
            role: 'member'
          }]);
        } catch (me) {
          console.warn('Member upsert error:', (me as Error).message);
        }
      }

      return res.json({
        success: true,
        message: `Você entrou na viagem "${trip.title}" com sucesso! 🎉`,
        data: trip
      });
    }
  } catch (e) {
    console.warn('Supabase join query error:', (e as Error).message);
  }

  // Memory fallback
  const found = trips.find(t => ((t as any).shareCode || '').toUpperCase() === cleanCode);
  if (found) {
    if (userId || userEmail) {
      tripMembers.push({
        id: `mem-${Date.now()}`,
        tripId: found.id,
        userId: userId ? String(userId) : undefined,
        userEmail: userEmail ? String(userEmail) : undefined,
        userName: userName ? String(userName) : 'Familiar',
        role: 'member',
        joinedAt: new Date().toISOString()
      });
    }
    return res.json({
      success: true,
      message: `Você entrou na viagem "${found.title}" com sucesso! 🎉`,
      data: found
    });
  }

  return res.status(404).json({
    success: false,
    message: `Código "${cleanCode}" não encontrado. Verifique se digitou corretamente.`
  });
});

// GET single trip details
tripsRouter.get('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const { data, error } = await supabase.from('trips').select('*').eq('id', id).maybeSingle();
    if (!error && data) {
      return res.json({
        success: true,
        data: {
          id: data.id,
          ownerId: data.owner_id ?? data.ownerId,
          shareCode: data.share_code ?? data.shareCode,
          title: data.title,
          destination: data.destination,
          state: data.state,
          startDate: data.start_date ?? data.startDate,
          endDate: data.end_date ?? data.endDate,
          tripDates: data.trip_dates ?? data.tripDates,
          imageUrl: data.image_url ?? data.imageUrl,
          status: data.status,
          tag: data.tag,
          budget: data.budget,
          totalDays: data.total_days ?? data.totalDays
        }
      });
    }
  } catch (e) {
    console.warn('Supabase trip query failed:', (e as Error).message);
  }

  const trip = trips.find(t => t.id === id);
  if (!trip) {
    return res.status(404).json({ success: false, message: 'Viagem não encontrada' });
  }
  return res.json({ success: true, data: trip });
});

// POST create new trip (with automatic unique share_code and owner_id)
tripsRouter.post('/', async (req: Request, res: Response) => {
  const { title, destination, state, startDate, endDate, tripDates, imageUrl, budget, totalDays, ownerId, ownerEmail, ownerName } = req.body;
  if (!title || !destination) {
    return res.status(400).json({ success: false, message: 'Título e destino são obrigatórios' });
  }

  let calculatedDays = totalDays ? parseInt(totalDays, 10) : 5;
  if (!totalDays && startDate && endDate) {
    const s = new Date(startDate);
    const e = new Date(endDate);
    const diff = Math.ceil((e.getTime() - s.getTime()) / (1000 * 60 * 60 * 24)) + 1;
    if (diff > 0 && diff < 365) calculatedDays = diff;
  }

  const shareCode = generateShareCode(destination);
  const tripId = `trip-${Date.now()}`;

  const newTrip: TripItem & { ownerId?: string; shareCode: string } = {
    id: tripId,
    ownerId: ownerId || undefined,
    shareCode,
    title,
    destination,
    state: state || 'Brasil',
    startDate: startDate || new Date().toISOString().split('T')[0],
    endDate: endDate || new Date().toISOString().split('T')[0],
    tripDates: tripDates || `${startDate || 'Em breve'} - ${endDate || ''}`,
    imageUrl: imageUrl || 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    status: 'planned',
    tag: 'Planejada',
    budget: budget ? parseFloat(budget) : 3000,
    totalDays: calculatedDays
  };

  // Add to memory list so it is always present
  trips.unshift(newTrip);

  if (ownerId || ownerEmail) {
    tripMembers.push({
      id: `mem-${Date.now()}`,
      tripId,
      userId: ownerId,
      userEmail: ownerEmail,
      userName: ownerName || 'Organizador',
      role: 'organizer',
      joinedAt: new Date().toISOString()
    });
  }

  try {
    const { error: insertErr } = await supabase.from('trips').insert([{
      id: newTrip.id,
      owner_id: newTrip.ownerId || null,
      share_code: newTrip.shareCode,
      title: newTrip.title,
      destination: newTrip.destination,
      state: newTrip.state,
      start_date: newTrip.startDate,
      end_date: newTrip.endDate,
      trip_dates: newTrip.tripDates,
      image_url: newTrip.imageUrl,
      status: newTrip.status,
      tag: newTrip.tag,
      budget: newTrip.budget,
      total_days: newTrip.totalDays
    }]);

    if (insertErr) {
      console.warn('Supabase trip insert error, trying legacy schema insert:', insertErr.message);
      const { error: retryErr } = await supabase.from('trips').insert([{
        id: newTrip.id,
        title: newTrip.title,
        destination: newTrip.destination,
        state: newTrip.state,
        start_date: newTrip.startDate,
        end_date: newTrip.endDate,
        trip_dates: newTrip.tripDates,
        image_url: newTrip.imageUrl,
        status: newTrip.status,
        tag: newTrip.tag,
        budget: newTrip.budget,
        total_days: newTrip.totalDays
      }]);
      if (retryErr) {
        console.warn('Supabase retry insert error:', retryErr.message);
      } else {
        console.log('✅ Viagem salva no Supabase com sucesso (esquema padrão):', newTrip.id);
      }
    } else {
      console.log('✅ Viagem salva no Supabase com sucesso:', newTrip.id);
    }

    if (ownerId || ownerEmail) {
      try {
        await supabase.from('trip_members').insert([{
          id: `member-${newTrip.id}-${ownerId || ownerEmail}`,
          trip_id: newTrip.id,
          user_id: ownerId || null,
          user_email: ownerEmail || null,
          user_name: ownerName || 'Organizador',
          role: 'organizer'
        }]);
      } catch (me) {
        console.warn('Supabase member insert warning:', (me as Error).message);
      }
    }
  } catch (e) {
    console.warn('Supabase trip insert failed:', (e as Error).message);
  }

  return res.status(201).json({ success: true, data: newTrip });
});

// DELETE trip by ID
tripsRouter.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  trips = trips.filter(t => t.id !== id);
  tripMembers = tripMembers.filter(m => m.tripId !== id);

  try {
    await supabase.from('trips').delete().eq('id', id);
  } catch (e) {
    console.warn('Supabase trip delete failed:', (e as Error).message);
  }

  return res.json({ success: true, message: 'Viagem removida com sucesso' });
});

// GET aggregated dashboard for a specific trip (100% dynamic per tripId)
tripsRouter.get('/:id/dashboard', async (req: Request, res: Response) => {
  const { id } = req.params;

  let currentTrip: (TripItem & { ownerId?: string; shareCode?: string }) | null = null;
  let itinerariesList: any[] = [];
  let stayData: any = null;
  let diningList: any[] = [];
  let expensesList: any[] = [];
  let packingList: any[] = [];
  let contactsList: any[] = [];

  try {
    // 1. Fetch trip
    const { data: tripRow } = await supabase.from('trips').select('*').eq('id', id).maybeSingle();
    if (tripRow) {
      currentTrip = {
        id: tripRow.id,
        ownerId: tripRow.owner_id ?? tripRow.ownerId,
        shareCode: tripRow.share_code ?? tripRow.shareCode,
        title: tripRow.title,
        destination: tripRow.destination,
        state: tripRow.state,
        startDate: tripRow.start_date ?? tripRow.startDate,
        endDate: tripRow.end_date ?? tripRow.endDate,
        tripDates: tripRow.trip_dates ?? tripRow.tripDates,
        imageUrl: tripRow.image_url ?? tripRow.imageUrl,
        status: tripRow.status,
        tag: tripRow.tag,
        budget: tripRow.budget,
        totalDays: tripRow.total_days ?? tripRow.totalDays
      };
    }

    // 2. Fetch itineraries
    const { data: itRows } = await supabase.from('itineraries').select('*').eq('trip_id', id).order('day', { ascending: true });
    if (itRows && itRows.length > 0) {
      itinerariesList = itRows.map((d: any) => ({
        id: d.id,
        tripId: d.trip_id ?? d.tripId,
        day: d.day,
        date: d.date,
        title: d.title,
        location: d.location,
        description: d.description,
        time: d.time,
        tideTime: d.tide_time ?? d.tideTime,
        status: d.status,
        tag: d.tag,
        imageUrl: d.image_url ?? d.imageUrl
      }));
    }

    // 3. Fetch stay
    const { data: stayRow } = await supabase.from('stay').select('*').eq('trip_id', id).maybeSingle();
    if (stayRow) {
      stayData = {
        id: stayRow.id,
        name: stayRow.name,
        address: stayRow.address,
        neighborhood: stayRow.neighborhood,
        checkIn: stayRow.check_in ?? stayRow.checkIn,
        checkOut: stayRow.check_out ?? stayRow.checkOut,
        bookingCode: stayRow.booking_code ?? stayRow.bookingCode,
        wifiNetwork: stayRow.wifi_network ?? stayRow.wifiNetwork,
        wifiPassword: stayRow.wifi_password ?? stayRow.wifiPassword,
        hostContact: stayRow.host_contact ?? stayRow.hostContact
      };
    }

    // If stay table had no record, check if there is an accommodation activity in itineraries
    if (!stayData && itinerariesList.length > 0) {
      const stayActivity = itinerariesList.find(i => {
        const text = `${i.title || ''} ${i.tag || ''} ${i.description || ''}`.toLowerCase();
        return text.includes('hospedagem') || text.includes('hotel') || text.includes('pousada') || text.includes('check-in') || text.includes('check in') || text.includes('airbnb') || text.includes('resort') || text.includes('estadia') || text.includes('chalé') || text.includes('chale');
      });

      if (stayActivity) {
        stayData = {
          id: stayActivity.id,
          name: stayActivity.title,
          address: stayActivity.location || '',
          neighborhood: '',
          checkIn: stayActivity.time || '14:00',
          checkOut: '11:00',
          bookingCode: '',
          wifiNetwork: '',
          wifiPassword: '',
          hostContact: ''
        };
      }
    }

    // 4. Fetch expenses
    const { data: expRows } = await supabase.from('expenses').select('*').eq('trip_id', id);
    if (expRows) expensesList = expRows;

    // 5. Fetch dining
    const { data: dinRows } = await supabase.from('dining').select('*').eq('trip_id', id);
    if (dinRows) diningList = dinRows;

    // 6. Fetch packing
    const { data: packRows } = await supabase.from('packing_items').select('*').eq('trip_id', id);
    if (packRows) packingList = packRows;

    // 7. Fetch contacts
    const { data: ctRows } = await supabase.from('contacts').select('*').eq('trip_id', id);
    if (ctRows) contactsList = ctRows;
  } catch (e) {
    console.warn('Dashboard Supabase fetch error:', (e as Error).message);
  }

  // Fallback to in-memory if trip is default Maceio and not in Supabase yet
  if (!currentTrip) {
    currentTrip = trips.find(t => t.id === id) || {
      id,
      shareCode: 'PARTIU-2026',
      title: 'Minha Viagem',
      destination: 'Destino',
      state: 'Brasil',
      startDate: new Date().toISOString().split('T')[0],
      endDate: new Date().toISOString().split('T')[0],
      tripDates: 'Em breve',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      status: 'planned',
      tag: 'Planejada',
      budget: 3000,
      totalDays: 5
    };
  }

  if (id === 'trip-maceio' && itinerariesList.length === 0) {
    itinerariesList = initialItineraries.filter(i => !i.tripId || i.tripId === 'trip-maceio');
  }
  if (id === 'trip-maceio' && !stayData) {
    stayData = initialStay;
  }
  if (id === 'trip-maceio' && diningList.length === 0) {
    diningList = initialDining;
  }
  if (id === 'trip-maceio' && expensesList.length === 0) {
    expensesList = initialExpenses;
  }
  if (id === 'trip-maceio' && packingList.length === 0) {
    packingList = initialPacking;
  }
  if (id === 'trip-maceio' && contactsList.length === 0) {
    contactsList = initialContacts;
  }

  const totalExpenses = expensesList.reduce((acc, curr) => acc + (parseFloat(curr.amount) || 0), 0);
  const packedCount = packingList.filter(p => p.isPacked || p.is_packed).length;
  const totalPacking = packingList.length;

  // Next planned tour (not completed) or first tour
  const nextTour = itinerariesList.find(i => i.status !== 'completed') || itinerariesList[0] || null;
  const nextDinner = diningList[0] || null;

  return res.json({
    success: true,
    data: {
      trip: currentTrip,
      destination: {
        city: currentTrip.destination,
        state: currentTrip.state,
        title: currentTrip.title,
        tripDates: currentTrip.tripDates,
        weather: {
          temp: '29°C',
          condition: 'Ensolarado',
          waterTemp: '27°C'
        }
      },
      staySnapshot: stayData,
      nextTour,
      nextDinner,
      stats: {
        totalDays: currentTrip.totalDays || itinerariesList.length || 5,
        totalExpenses,
        packingProgress: totalPacking > 0 ? Math.round((packedCount / totalPacking) * 100) : 0,
        totalContacts: contactsList.length
      }
    }
  });
});
