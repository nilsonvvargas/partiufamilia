import { Router, Request, Response } from 'express';
import { initialExpenses, ExpenseItem } from '../../data/seedData';
import { supabase } from '../../config/supabase';

export const expensesRouter = Router();
let expenses: ExpenseItem[] = [];

// GET all expenses + financial summary
expensesRouter.get('/', async (req: Request, res: Response) => {
  const { tripId } = req.query;
  let list = expenses;

  try {
    let query = supabase.from('expenses').select('*').order('date', { ascending: false });
    if (tripId) {
      query = query.eq('trip_id', String(tripId));
    }

    const { data, error } = await query;
    if (!error && data) {
      list = data.map((d: any) => ({
        id: d.id,
        tripId: d.trip_id ?? d.tripId,
        title: d.title,
        amount: Number(d.amount),
        category: d.category,
        paidBy: d.paid_by ?? d.paidBy,
        splitWith: d.split_with ?? d.splitWith ?? [],
        date: d.date
      }));
      const totalAmount = list.reduce((acc, curr) => acc + Number(curr.amount), 0);
      const byCategory = list.reduce((acc: Record<string, number>, curr) => {
        acc[curr.category] = (acc[curr.category] || 0) + Number(curr.amount);
        return acc;
      }, {});

      return res.json({
        success: true,
        data: {
          items: list,
          summary: {
            totalAmount,
            byCategory,
            count: list.length
          }
        },
        source: 'supabase'
      });
    }
  } catch (e) {
    console.warn('Supabase expenses query failed, using local store:', (e as Error).message);
  }

  const filtered = tripId
    ? list.filter(e => !e.tripId || e.tripId === tripId)
    : list;

  const totalAmount = filtered.reduce((acc, curr) => acc + Number(curr.amount), 0);
  const byCategory = filtered.reduce((acc: Record<string, number>, curr) => {
    acc[curr.category] = (acc[curr.category] || 0) + Number(curr.amount);
    return acc;
  }, {});

  return res.json({
    success: true,
    data: {
      items: filtered,
      summary: {
        totalAmount,
        totalItems: filtered.length,
        byCategory
      }
    }
  });
});

// POST new expense
expensesRouter.post('/', async (req: Request, res: Response) => {
  const { title, amount, category, paidBy, splitWith, date, tripId } = req.body;
  if (!title || !amount || !category) {
    return res.status(400).json({ success: false, message: 'Título, valor e categoria são obrigatórios' });
  }

  const newExpense: ExpenseItem = {
    id: `exp-${Date.now()}`,
    tripId: tripId || 'trip-maceio',
    title,
    amount: parseFloat(amount),
    category,
    paidBy: paidBy || 'Nilson',
    splitWith: splitWith || ['Nilson'],
    date: date || new Date().toISOString().split('T')[0]
  };

  expenses.unshift(newExpense);

  try {
    await supabase.from('expenses').insert([{
      id: newExpense.id,
      trip_id: newExpense.tripId,
      title: newExpense.title,
      amount: newExpense.amount,
      category: newExpense.category,
      paid_by: newExpense.paidBy,
      split_with: newExpense.splitWith,
      date: newExpense.date
    }]);
  } catch (e) {
    console.warn('Supabase insert expense failed:', (e as Error).message);
  }

  return res.status(201).json({ success: true, data: newExpense });
});

// PUT update expense
expensesRouter.put('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { title, amount, category, paidBy, splitWith, date } = req.body;

  const itemIndex = expenses.findIndex(e => e.id === id);
  if (itemIndex === -1) {
    return res.status(404).json({ success: false, message: 'Despesa não encontrada' });
  }

  expenses[itemIndex] = {
    ...expenses[itemIndex],
    ...(title && { title }),
    ...(amount !== undefined && { amount: parseFloat(amount) }),
    ...(category && { category }),
    ...(paidBy && { paidBy }),
    ...(splitWith && { splitWith }),
    ...(date && { date })
  };

  const updated = expenses[itemIndex];

  try {
    await supabase.from('expenses').update({
      title: updated.title,
      amount: updated.amount,
      category: updated.category,
      paid_by: updated.paidBy,
      split_with: updated.splitWith,
      date: updated.date
    }).eq('id', id);
  } catch (e) {
    console.warn('Supabase update expense failed:', (e as Error).message);
  }

  return res.json({ success: true, data: updated });
});

// DELETE expense
expensesRouter.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  expenses = expenses.filter(e => e.id !== id);

  try {
    await supabase.from('expenses').delete().eq('id', id);
  } catch (e) {
    console.warn('Supabase delete expense failed:', (e as Error).message);
  }

  return res.json({ success: true, message: 'Despesa removida' });
});
