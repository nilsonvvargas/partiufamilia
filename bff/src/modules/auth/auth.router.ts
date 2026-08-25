import { Router, Request, Response } from 'express';
import { supabase } from '../../config/supabase';

export const authRouter = Router();

// POST login via Supabase Auth
authRouter.post('/login', async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'E-mail e senha são obrigatórios' });
  }

  try {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      return res.status(401).json({ success: false, message: error.message });
    }

    const user = data.user;
    const session = data.session;

    return res.json({
      success: true,
      data: {
        token: session?.access_token ?? '',
        user: {
          id: user?.id ?? '',
          name: user?.user_metadata?.name ?? user?.email?.split('@')[0] ?? 'Viajante',
          email: user?.email ?? email,
          role: user?.user_metadata?.role ?? 'Viajante',
          avatar: user?.user_metadata?.avatar ?? '✈️',
        }
      }
    });
  } catch (e) {
    console.error('Supabase auth error:', e);
    return res.status(500).json({ success: false, message: 'Erro interno de autenticação' });
  }
});

// POST signup via Supabase Auth
authRouter.post('/signup', async (req: Request, res: Response) => {
  const { email, password, name } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'E-mail e senha são obrigatórios' });
  }

  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { name: name || email.split('@')[0], role: 'Viajante', avatar: '✈️' }
      }
    });

    if (error) {
      return res.status(400).json({ success: false, message: error.message });
    }

    const user = data.user;

    return res.status(201).json({
      success: true,
      data: {
        user: {
          id: user?.id ?? '',
          name: name || (user?.email?.split('@')[0] ?? 'Viajante'),
          email: user?.email ?? email,
          role: 'Viajante',
          avatar: '✈️',
        },
        message: 'Conta criada com sucesso!'
      }
    });
  } catch (e) {
    console.error('Supabase signup error:', e);
    return res.status(500).json({ success: false, message: 'Erro interno ao criar conta' });
  }
});

// POST logout
authRouter.post('/logout', async (req: Request, res: Response) => {
  try {
    await supabase.auth.signOut();
    return res.json({ success: true, message: 'Logout realizado com sucesso' });
  } catch (e) {
    return res.json({ success: true, message: 'Sessão finalizada' });
  }
});
