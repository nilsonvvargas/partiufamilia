import { Router, Request, Response } from 'express';
import { initialPacking, PackingItem } from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const packingRouter = Router();
let packingList: PackingItem[] = [];

// GET packing items with stats
packingRouter.get('/', async (req: Request, res: Response) => {
  const { tripId } = req.query;
  let list = packingList;

  try {
    let query = supabase.from('packing_items').select('*');
    if (tripId) {
      query = query.eq('trip_id', String(tripId));
    }

    const { data, error } = await query;
    if (!error && data) {
      list = data.map((item: any) => ({
        id: item.id,
        tripId: item.trip_id ?? item.tripId,
        name: item.name,
        category: item.category,
        member: item.member ?? 'Todos',
        isPacked: item.is_packed ?? item.isPacked,
        quantity: item.quantity ?? 1
      }));
      const packedCount = list.filter(i => i.isPacked).length;
      const totalCount = list.length;
      const progressPercentage = totalCount > 0 ? Math.round((packedCount / totalCount) * 100) : 0;

      return res.json({
        success: true,
        data: {
          items: list,
          stats: {
            total: totalCount,
            packed: packedCount,
            progressPercentage
          }
        },
        source: 'supabase'
      });
    }
  } catch (e) {
    console.warn('Supabase packing query failed, using local store:', (e as Error).message);
  }

  const filtered = tripId
    ? list.filter(i => !i.tripId || i.tripId === tripId)
    : list;

  const packedCount = filtered.filter(i => i.isPacked).length;
  const totalCount = filtered.length;
  const progressPercentage = totalCount > 0 ? Math.round((packedCount / totalCount) * 100) : 0;

  return res.json({
    success: true,
    data: {
      items: filtered,
      stats: {
        packedCount,
        totalCount,
        progressPercentage
      }
    }
  });
});

// POST new packing item
packingRouter.post('/', async (req: Request, res: Response) => {
  const { name, category, quantity, member, tripId } = req.body;
  if (!name || !category) {
    return res.status(400).json({ success: false, message: 'Nome e categoria são obrigatórios' });
  }

  const newItem: PackingItem = {
    id: `pack-${Date.now()}`,
    tripId: tripId || 'trip-maceio',
    name,
    category,
    member: member || 'Todos',
    isPacked: false,
    quantity: quantity ? parseInt(quantity) : 1
  };

  packingList.push(newItem);

  try {
    await supabase.from('packing_items').insert([{
      id: newItem.id,
      trip_id: newItem.tripId,
      name: newItem.name,
      category: newItem.category,
      member: newItem.member,
      is_packed: false,
      quantity: newItem.quantity
    }]);
  } catch (e) {
    console.warn('Supabase packing insert failed:', (e as Error).message);
  }

  return res.status(201).json({ success: true, data: newItem });
});

// PUT update packing item
packingRouter.put('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { name, category, quantity, member, isPacked } = req.body;

  const itemIndex = packingList.findIndex(p => p.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Item não encontrado' });
  }

  packingList[itemIndex] = {
    ...packingList[itemIndex],
    ...(name && { name }),
    ...(category && { category }),
    ...(member && { member }),
    ...(quantity !== undefined && { quantity: parseInt(quantity) }),
    ...(isPacked !== undefined && { isPacked })
  };

  const updated = packingList[itemIndex];

  try {
    await supabase.from('packing_items').update({
      name: updated.name,
      category: updated.category,
      member: updated.member,
      quantity: updated.quantity,
      is_packed: updated.isPacked
    }).eq('id', id);
  } catch (e) {
    console.warn('Supabase packing update failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updated });
});


// DELETE packing item
packingRouter.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  packingList = packingList.filter(p => p.id !== id);

  try {
    await supabase.from('packing_items').delete().eq('id', id);
  } catch (e) {
    console.warn('Supabase packing delete failed:', (e as Error).message);
  }

  return res.json({ success: true, message: 'Item removido da mala' });
});

// PATCH toggle isPacked
packingRouter.patch('/:id/toggle', async (req: Request, res: Response) => {
  const { id } = req.params;
  const itemIndex = packingList.findIndex(p => p.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Item não encontrado' });
  }

  packingList[itemIndex].isPacked = !packingList[itemIndex].isPacked;
  const updatedItem = packingList[itemIndex];

  try {
    await supabase.from('packing_items').update({ is_packed: updatedItem.isPacked }).eq('id', id);
  } catch (e) {
    console.warn('Supabase packing update failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updatedItem });
});
