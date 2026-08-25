import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://tshoyechnrdigebnmwql.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY || 'sb_publishable_VcrsQs6emj0GFE20-5G_Tw_Qiq9vyDM';

export const supabase = createClient(supabaseUrl, supabaseKey);
