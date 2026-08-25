import { Router, Request, Response } from 'express';
import { initialDining, DiningItem } from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const diningRouter = Router();
let dinings: DiningItem[] = [];

// GET all dining places (optionally filtered by tripId)
diningRouter.get('/', async (req: Request, res: Response) => {
  const { tripId } = req.query;

  try {
    let query = supabase.from('dining').select('*');
    if (tripId) {
      query = query.eq('trip_id', String(tripId));
    }

    const { data, error } = await query;
    if (!error && data) {
      const mapped = data.map((d: any) => ({
        id: d.id,
        tripId: d.trip_id ?? d.tripId,
        name: d.name,
        cuisine: d.cuisine,
        specialty: d.specialty,
        address: d.address,
        reservationTime: d.reservation_time ?? d.reservationTime,
        rating: Number(d.rating ?? 5.0),
        status: d.status,
        notes: d.notes ?? ''
      }));
      return res.json({ success: true, data: mapped, source: 'supabase' });
    }
  } catch (e) {
    console.warn('Supabase dining query failed, using local store:', (e as Error).message);
  }

  const filtered = tripId
    ? dinings.filter(d => !d.tripId || d.tripId === tripId)
    : dinings;

  return res.json({ success: true, data: filtered, source: 'memory' });
});

// POST add restaurant reservation/plan
diningRouter.post('/', async (req: Request, res: Response) => {
  const { name, cuisine, specialty, address, reservationTime, rating, status, notes, tripId } = req.body;

  if (!name) {
    return res.status(400).json({ success: false, message: 'Nome do restaurante é obrigatório' });
  }

  const newDining: DiningItem = {
    id: `din-${Date.now()}`,
    tripId: tripId || 'trip-maceio',
    name,
    cuisine: cuisine || 'Regional',
    specialty: specialty || 'Frutos do Mar',
    address: address || 'Maceió, AL',
    reservationTime: reservationTime || '20:00',
    rating: rating ? parseFloat(rating) : 4.8,
    status: status || 'planejado',
    notes: notes || ''
  };

  dinings.push(newDining);

  try {
    await supabase.from('dining').insert([{
      id: newDining.id,
      trip_id: newDining.tripId,
      name: newDining.name,
      cuisine: newDining.cuisine,
      specialty: newDining.specialty,
      address: newDining.address,
      reservation_time: newDining.reservationTime,
      rating: newDining.rating,
      status: newDining.status,
      notes: newDining.notes
    }]);
  } catch (e) {
    console.warn('Supabase dining insert failed:', (e as Error).message);
  }

  return res.status(201).json({ success: true, data: newDining });
});

// PUT update dining item
diningRouter.put('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { name, cuisine, specialty, address, reservationTime, rating, status, notes } = req.body;

  const itemIndex = dinings.findIndex(d => d.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Restaurante não encontrado' });
  }

  dinings[itemIndex] = {
    ...dinings[itemIndex],
    ...(name && { name }),
    ...(cuisine && { cuisine }),
    ...(specialty && { specialty }),
    ...(address && { address }),
    ...(reservationTime && { reservationTime }),
    ...(rating !== undefined && { rating: parseFloat(rating) }),
    ...(status && { status }),
    ...(notes !== undefined && { notes })
  };

  const updated = dinings[itemIndex];

  try {
    await supabase.from('dining').update({
      name: updated.name,
      cuisine: updated.cuisine,
      specialty: updated.specialty,
      address: updated.address,
      reservation_time: updated.reservationTime,
      rating: updated.rating,
      status: updated.status,
      notes: updated.notes
    }).eq('id', id);
  } catch (e) {
    console.warn('Supabase dining update failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updated });
});

// DELETE dining item
diningRouter.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  dinings = dinings.filter(d => d.id !== id);

  try {
    await supabase.from('dining').delete().eq('id', id);
  } catch (e) {
    console.warn('Supabase dining delete failed:', (e as Error).message);
  }

  return res.json({ success: true, message: 'Restaurante removido com sucesso' });
});

// PATCH status (e.g. reservado, visitado)
diningRouter.patch('/:id/status', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;

  const itemIndex = dinings.findIndex(d => d.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Restaurante não encontrado' });
  }

  dinings[itemIndex].status = status;

  try {
    await supabase.from('dining').update({ status }).eq('id', id);
  } catch (e) {
    console.warn('Supabase dining update failed:', (e as Error).message);
  }

  return res.json({ success: true, data: dinings[itemIndex] });
});
