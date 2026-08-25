import { Router, Request, Response } from 'express';
import { initialContacts, ContactItem } from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const contactsRouter = Router();
let contacts: ContactItem[] = [];

// GET all contacts
contactsRouter.get('/', async (req: Request, res: Response) => {
  const { tripId } = req.query;

  try {
    let query = supabase.from('contacts').select('*');
    if (tripId) {
      query = query.eq('trip_id', String(tripId));
    }

    const { data, error } = await query;
    if (!error && data) {
      const mapped = data.map((d: any) => ({
        id: d.id,
        tripId: d.trip_id ?? d.tripId,
        name: d.name,
        role: d.role,
        phone: d.phone,
        whatsapp: d.whatsapp,
        location: d.location,
        notes: d.notes ?? ''
      }));
      return res.json({ success: true, data: mapped, source: 'supabase' });
    }
  } catch (e) {
    console.warn('Supabase contacts query failed, using local store:', (e as Error).message);
  }

  const filtered = tripId
    ? contacts.filter(c => !c.tripId || c.tripId === tripId)
    : contacts;

  return res.json({ success: true, data: filtered, source: 'memory' });
});

// POST new contact
contactsRouter.post('/', async (req: Request, res: Response) => {
  const { name, role, phone, whatsapp, location, notes, tripId } = req.body;

  if (!name || !phone) {
    return res.status(400).json({ success: false, message: 'Nome e telefone são obrigatórios' });
  }

  const newContact: ContactItem = {
    id: `ct-${Date.now()}`,
    tripId: tripId || 'trip-maceio',
    name,
    role: role || 'Guia de Lancha',
    phone,
    whatsapp: whatsapp || phone,
    location: location || 'Maceió, AL',
    notes: notes || ''
  };

  contacts.push(newContact);

  try {
    await supabase.from('contacts').insert([{
      id: newContact.id,
      trip_id: newContact.tripId,
      name: newContact.name,
      role: newContact.role,
      phone: newContact.phone,
      whatsapp: newContact.whatsapp,
      location: newContact.location,
      notes: newContact.notes
    }]);
  } catch (e) {
    console.warn('Supabase contact insert failed:', (e as Error).message);
  }

  return res.status(201).json({ success: true, data: newContact });
});

// PUT update contact
contactsRouter.put('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { name, role, phone, whatsapp, location, notes } = req.body;

  const itemIndex = contacts.findIndex(c => c.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Contato não encontrado' });
  }

  contacts[itemIndex] = {
    ...contacts[itemIndex],
    ...(name && { name }),
    ...(role && { role }),
    ...(phone && { phone }),
    ...(whatsapp && { whatsapp }),
    ...(location && { location }),
    ...(notes !== undefined && { notes })
  };

  const updated = contacts[itemIndex];

  try {
    await supabase.from('contacts').update({
      name: updated.name,
      role: updated.role,
      phone: updated.phone,
      whatsapp: updated.whatsapp,
      location: updated.location,
      notes: updated.notes
    }).eq('id', id);
  } catch (e) {
    console.warn('Supabase contact update failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updated });
});

// DELETE contact
contactsRouter.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  contacts = contacts.filter(c => c.id !== id);

  try {
    await supabase.from('contacts').delete().eq('id', id);
  } catch (e) {
    console.warn('Supabase contact delete failed:', (e as Error).message);
  }

  return res.json({ success: true, message: 'Contato removido com sucesso' });
});
