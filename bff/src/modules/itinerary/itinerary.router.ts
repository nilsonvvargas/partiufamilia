import { Router, Request, Response } from 'express';
import { initialItineraries, ItineraryItem } from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const itineraryRouter = Router();
let itineraries: ItineraryItem[] = [];

// GET all itinerary items (optionally filtered by tripId)
itineraryRouter.get('/', async (req: Request, res: Response) => {
  const { tripId } = req.query;

  try {
    let query = supabase.from('itineraries').select('*').order('day', { ascending: true });
    if (tripId) {
      query = query.eq('trip_id', String(tripId));
    }

    const { data, error } = await query;
    if (!error && data) {
      const mapped = data.map((d: any) => ({
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
      return res.json({ success: true, data: mapped, source: 'supabase' });
    }
  } catch (e) {
    console.warn('Supabase query failed, using local store:', (e as Error).message);
  }

  const filtered = tripId
    ? itineraries.filter(i => !i.tripId || i.tripId === tripId)
    : itineraries;

  return res.json({ success: true, data: filtered, source: 'memory' });
});

// GET itinerary by ID
itineraryRouter.get('/:id', (req: Request, res: Response) => {
  const { id } = req.params;
  const item = itineraries.find(i => i.id === id);
  if (!item) {
    return res.status(404).json({ success: false, message: 'Passeio não encontrado' });
  }
  return res.json({ success: true, data: item });
});

// POST add new itinerary item
itineraryRouter.post('/', async (req: Request, res: Response) => {
  const { title, day, location, description, time, tideTime, tag, imageUrl, status, tripId, date } = req.body;

  if (!title) {
    return res.status(400).json({ success: false, message: 'Título do passeio é obrigatório' });
  }

  const newItem: ItineraryItem = {
    id: `it-${Date.now()}`,
    tripId: tripId || 'trip-maceio',
    day: day ? parseInt(day, 10) : 1,
    date: date || 'Em breve',
    title,
    location: location || 'Maceió, AL',
    description: description || '',
    time: time || '09:00',
    tideTime: tideTime || undefined,
    status: status || 'planned',
    tag: tag || 'Passeio',
    imageUrl: imageUrl || 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80'
  };

  itineraries.push(newItem);

  try {
    await supabase.from('itineraries').insert([{
      id: newItem.id,
      trip_id: newItem.tripId,
      day: newItem.day,
      date: newItem.date,
      title: newItem.title,
      location: newItem.location,
      description: newItem.description,
      time: newItem.time,
      tide_time: newItem.tideTime,
      status: newItem.status,
      tag: newItem.tag,
      image_url: newItem.imageUrl
    }]);
  } catch (e) {
    console.warn('Supabase insert failed:', (e as Error).message);
  }

  return res.status(201).json({ success: true, data: newItem });
});

// PUT update itinerary item
itineraryRouter.put('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { title, day, location, description, time, tideTime, tag, imageUrl, status, date } = req.body;

  const itemIndex = itineraries.findIndex(i => i.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Passeio não encontrado' });
  }

  itineraries[itemIndex] = {
    ...itineraries[itemIndex],
    ...(title && { title }),
    ...(day !== undefined && { day: parseInt(day, 10) }),
    ...(location && { location }),
    ...(description !== undefined && { description }),
    ...(time && { time }),
    ...(tideTime !== undefined && { tideTime }),
    ...(tag && { tag }),
    ...(imageUrl && { imageUrl }),
    ...(status && { status }),
    ...(date && { date })
  };

  const updated = itineraries[itemIndex];

  try {
    await supabase.from('itineraries').update({
      title: updated.title,
      day: updated.day,
      location: updated.location,
      description: updated.description,
      time: updated.time,
      tide_time: updated.tideTime,
      tag: updated.tag,
      image_url: updated.imageUrl,
      status: updated.status,
      date: updated.date
    }).eq('id', id);
  } catch (e) {
    console.warn('Supabase update failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updated });
});

// DELETE itinerary item
itineraryRouter.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const initialLength = itineraries.length;
  itineraries = itineraries.filter(i => i.id !== id);

  try {
    await supabase.from('itineraries').delete().eq('id', id);
  } catch (e) {
    console.warn('Supabase delete failed:', (e as Error).message);
  }

  if (itineraries.length === initialLength) {
    // still return success if removed or not found
    return res.json({ success: true, message: 'Passeio removido com sucesso' });
  }

  return res.json({ success: true, message: 'Passeio removido com sucesso' });
});

// PATCH toggle or update itinerary status
itineraryRouter.patch('/:id/status', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;

  const itemIndex = itineraries.findIndex(i => i.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Passeio não encontrado' });
  }

  itineraries[itemIndex].status = status;

  try {
    await supabase.from('itineraries').update({ status }).eq('id', id);
  } catch (e) {
    console.warn('Supabase update status failed:', (e as Error).message);
  }

  return res.json({ success: true, data: itineraries[itemIndex] });
});
