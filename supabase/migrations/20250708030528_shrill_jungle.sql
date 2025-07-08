-- Create market data cache table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.market_data_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT NOT NULL,
  name TEXT,
  price_usd NUMERIC NOT NULL,
  price_aud NUMERIC NOT NULL,
  volume_24h_usd NUMERIC,
  volume_24h_aud NUMERIC,
  change_24h NUMERIC,
  change_percentage_24h NUMERIC,
  market_cap_usd NUMERIC,
  market_cap_aud NUMERIC,
  high_24h NUMERIC,
  low_24h NUMERIC,
  exchange TEXT NOT NULL DEFAULT 'coingecko',
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create unique index on symbol
CREATE UNIQUE INDEX IF NOT EXISTS idx_market_data_cache_symbol ON public.market_data_cache(symbol);

-- Create index on last_updated for better performance
CREATE INDEX IF NOT EXISTS idx_market_data_cache_last_updated ON public.market_data_cache(last_updated);

-- Enable RLS on market data cache
ALTER TABLE public.market_data_cache ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for market data cache (public read access)
CREATE POLICY "Anyone can read market data" 
ON public.market_data_cache 
FOR SELECT 
USING (true);

-- Enable realtime for market data cache
ALTER PUBLICATION supabase_realtime ADD TABLE public.market_data_cache;
ALTER TABLE public.market_data_cache REPLICA IDENTITY FULL;

-- Insert initial market data
INSERT INTO public.market_data_cache (symbol, name, price_usd, price_aud, volume_24h_usd, volume_24h_aud, change_24h, change_percentage_24h, market_cap_usd, market_cap_aud)
VALUES
  ('BTC', 'Bitcoin', 50000, 75000, 30000000000, 45000000000, 1500, 3.0, 950000000000, 1425000000000),
  ('ETH', 'Ethereum', 3000, 4500, 15000000000, 22500000000, 100, 3.3, 350000000000, 525000000000),
  ('SOL', 'Solana', 150, 225, 5000000000, 7500000000, 10, 6.7, 60000000000, 90000000000),
  ('ADA', 'Cardano', 0.5, 0.75, 1000000000, 1500000000, 0.02, 4.0, 17000000000, 25500000000),
  ('DOT', 'Polkadot', 15, 22.5, 800000000, 1200000000, 0.5, 3.3, 15000000000, 22500000000),
  ('LINK', 'Chainlink', 20, 30, 700000000, 1050000000, 1, 5.0, 10000000000, 15000000000),
  ('UNI', 'Uniswap', 10, 15, 500000000, 750000000, 0.3, 3.0, 5000000000, 7500000000),
  ('AVAX', 'Avalanche', 30, 45, 900000000, 1350000000, 1.5, 5.0, 10000000000, 15000000000)
ON CONFLICT (symbol) DO NOTHING;