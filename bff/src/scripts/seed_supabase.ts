import { supabase } from '../config/supabase';
import {
  initialTrips,
  initialItineraries,
  initialExpenses,
  initialDining,
  initialStay,
  initialPacking,
  initialContacts
} from '../data/seedData';

export const sqlSchema = `
-- ==============================================================================
-- FAMÍLIA PARTIU! ✈️ - Script DDL Completo com Compartilhamento & Convites
-- Acesse: https://supabase.com/dashboard/project/tshoyechnrdigebnmwql/sql/new
-- ==============================================================================

-- 1. TABELA DE VIAGENS (TRIPS)
CREATE TABLE IF NOT EXISTS trips (
  id TEXT PRIMARY KEY,
  owner_id TEXT,
  share_code TEXT UNIQUE,
  title TEXT NOT NULL,
  destination TEXT NOT NULL,
  state TEXT DEFAULT 'Brasil',
  start_date TEXT,
  end_date TEXT,
  trip_dates TEXT,
  image_url TEXT,
  status TEXT DEFAULT 'planned',
  tag TEXT DEFAULT 'Planejada',
  budget NUMERIC DEFAULT 3000,
  total_days INT DEFAULT 5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. TABELA DE MEMBROS DA VIAGEM (TRIP_MEMBERS - MULTI-FAMÍLIA)
CREATE TABLE IF NOT EXISTS trip_members (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  user_id TEXT,
  user_email TEXT,
  user_name TEXT,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. TABELA DE ROTEIROS (ITINERARIES)
CREATE TABLE IF NOT EXISTS itineraries (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  day INT,
  date TEXT,
  title TEXT NOT NULL,
  location TEXT,
  description TEXT,
  time TEXT,
  tide_time TEXT,
  status TEXT DEFAULT 'planned',
  tag TEXT DEFAULT 'Passeio',
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. TABELA DE DESPESAS (EXPENSES)
CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  category TEXT NOT NULL,
  paid_by TEXT DEFAULT 'Nilson',
  split_with JSONB,
  date TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 5. TABELA DE JANTARES E GASTRONOMIA (DINING)
CREATE TABLE IF NOT EXISTS dining (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  cuisine TEXT,
  specialty TEXT,
  address TEXT,
  reservation_time TEXT,
  rating NUMERIC DEFAULT 5.0,
  status TEXT DEFAULT 'planejado',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 6. TABELA DE ESTADIA E HOSPEDAGEM (STAY)
CREATE TABLE IF NOT EXISTS stay (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT,
  neighborhood TEXT,
  check_in TEXT,
  check_out TEXT,
  booking_code TEXT,
  wifi_network TEXT,
  wifi_password TEXT,
  rules JSONB,
  amenities JSONB,
  host_contact TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 7. TABELA DE ITENS DA MALA (PACKING_ITEMS)
CREATE TABLE IF NOT EXISTS packing_items (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  is_packed BOOLEAN DEFAULT false,
  quantity INT DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 8. TABELA DE CONTATOS E GUIAS (CONTACTS)
CREATE TABLE IF NOT EXISTS contacts (
  id TEXT PRIMARY KEY,
  trip_id TEXT REFERENCES trips(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  role TEXT,
  phone TEXT,
  whatsapp TEXT,
  location TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- LIBERAR ACESSO DO APP (DISABLE RLS)
ALTER TABLE trips DISABLE ROW LEVEL SECURITY;
ALTER TABLE trip_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE itineraries DISABLE ROW LEVEL SECURITY;
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE dining DISABLE ROW LEVEL SECURITY;
ALTER TABLE stay DISABLE ROW LEVEL SECURITY;
ALTER TABLE packing_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE contacts DISABLE ROW LEVEL SECURITY;
`;

export function generateShareCode(destination: string): string {
  const cleanDest = destination.trim().split(' ')[0].toUpperCase().replace(/[^A-Z]/g, '');
  const prefix = cleanDest.length >= 3 ? cleanDest.substring(0, 4) : 'PARTIU';
  const randomNum = Math.floor(1000 + Math.random() * 9000);
  return `${prefix}-${randomNum}`;
}
