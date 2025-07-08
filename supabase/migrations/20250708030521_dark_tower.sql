-- Create portfolios table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.portfolios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL DEFAULT 'My Portfolio',
  mode TEXT NOT NULL DEFAULT 'paper' CHECK (mode IN ('paper', 'live')),
  initial_balance NUMERIC DEFAULT 10000.00,
  current_balance NUMERIC DEFAULT 10000.00,
  total_value NUMERIC DEFAULT 10000.00,
  total_pnl NUMERIC DEFAULT 0.00,
  total_pnl_percentage NUMERIC DEFAULT 0.00,
  positions JSONB DEFAULT '{}'::jsonb,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create watchlists table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.watchlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL DEFAULT 'My Watchlist',
  symbols TEXT[] DEFAULT '{}'::text[],
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on portfolios and watchlists
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlists ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for portfolios
CREATE POLICY "Users can manage their own portfolios" 
ON public.portfolios 
FOR ALL 
USING (auth.uid() = user_id);

-- Create RLS policies for watchlists
CREATE POLICY "Users can manage their own watchlists" 
ON public.watchlists 
FOR ALL 
USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON public.portfolios(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolios_is_default ON public.portfolios(is_default);
CREATE INDEX IF NOT EXISTS idx_watchlists_user_id ON public.watchlists(user_id);
CREATE INDEX IF NOT EXISTS idx_watchlists_is_default ON public.watchlists(is_default);

-- Enable realtime for portfolios and watchlists
ALTER PUBLICATION supabase_realtime ADD TABLE public.portfolios;
ALTER PUBLICATION supabase_realtime ADD TABLE public.watchlists;
ALTER TABLE public.portfolios REPLICA IDENTITY FULL;
ALTER TABLE public.watchlists REPLICA IDENTITY FULL;