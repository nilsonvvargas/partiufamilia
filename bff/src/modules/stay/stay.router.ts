import { Router, Request, Response } from 'express';
import { initialStay, StayItem } from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const stayRouter = Router();

// In-memory store per tripId
let stays: StayItem[] = [
  { ...initialStay, tripId: 'trip-maceio' }
];

// GET accommodation information by tripId
stayRouter.get('/', async (req: Request, res: Response) => {
  const { tripId } = req.query;
  const effectiveTripId = tripId ? String(tripId) : 'trip-maceio';

  try {
    const { data, error } = await supabase
      .from('stay')
      .select('*')
      .eq('trip_id', effectiveTripId)
      .maybeSingle();

    if (!error && data) {
      return res.json({
        success: true,
        data: {
          id: data.id,
          tripId: data.trip_id ?? data.tripId,
          name: data.name,
          address: data.address,
          neighborhood: data.neighborhood,
          checkIn: data.check_in ?? data.checkIn,
          checkOut: data.check_out ?? data.checkOut,
          bookingCode: data.booking_code ?? data.bookingCode,
          wifiNetwork: data.wifi_network ?? data.wifiNetwork,
          wifiPassword: data.wifi_password ?? data.wifiPassword,
          rules: data.rules ?? [],
          amenities: data.amenities ?? [],
          hostContact: data.host_contact ?? data.hostContact
        },
        source: 'supabase'
      });
    }
  } catch (e) {
    console.warn('Supabase stay query failed, using local store:', (e as Error).message);
  }

  const found = stays.find(s => s.tripId === effectiveTripId);
  return res.json({
    success: true,
    data: found || null,
    source: 'memory'
  });
});

// PUT update stay details for a specific trip
stayRouter.put('/', async (req: Request, res: Response) => {
  const { name, address, neighborhood, checkIn, checkOut, bookingCode, wifiNetwork, wifiPassword, hostContact, tripId } = req.body;
  const effectiveTripId = tripId ? String(tripId) : 'trip-maceio';

  let existingIndex = stays.findIndex(s => s.tripId === effectiveTripId);
  const stayId = existingIndex >= 0 ? stays[existingIndex].id : `stay-${Date.now()}`;

  const updatedStay: StayItem = {
    id: stayId,
    tripId: effectiveTripId,
    name: name || 'Hotel / Pousada',
    address: address || '',
    neighborhood: neighborhood || '',
    checkIn: checkIn || '14:00',
    checkOut: checkOut || '11:00',
    bookingCode: bookingCode || '',
    wifiNetwork: wifiNetwork || '',
    wifiPassword: wifiPassword || '',
    hostContact: hostContact || '',
    rules: existingIndex >= 0 ? stays[existingIndex].rules : [],
    amenities: existingIndex >= 0 ? stays[existingIndex].amenities : []
  };

  if (existingIndex >= 0) {
    stays[existingIndex] = updatedStay;
  } else {
    stays.push(updatedStay);
  }

  try {
    await supabase.from('stay').upsert([{
      id: updatedStay.id,
      trip_id: updatedStay.tripId,
      name: updatedStay.name,
      address: updatedStay.address,
      neighborhood: updatedStay.neighborhood,
      check_in: updatedStay.checkIn,
      check_out: updatedStay.checkOut,
      booking_code: updatedStay.bookingCode,
      wifi_network: updatedStay.wifiNetwork,
      wifi_password: updatedStay.wifiPassword,
      host_contact: updatedStay.hostContact,
      rules: updatedStay.rules,
      amenities: updatedStay.amenities
    }]);
  } catch (e) {
    console.warn('Supabase stay upsert failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updatedStay });
});
