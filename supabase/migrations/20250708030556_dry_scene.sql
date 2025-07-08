-- Create paper trades table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.paper_trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  account_id UUID REFERENCES public.paper_trading_accounts(id),
  bot_id UUID,
  symbol TEXT NOT NULL,
  side TEXT NOT NULL CHECK (side IN ('buy', 'sell')),
  amount NUMERIC NOT NULL DEFAULT 0,
  price NUMERIC NOT NULL DEFAULT 0,
  execution_price NUMERIC DEFAULT 0,
  total_value NUMERIC NOT NULL DEFAULT 0,
  fee NUMERIC NOT NULL DEFAULT 0,
  trade_type TEXT DEFAULT 'market',
  order_type TEXT DEFAULT 'market',
  status TEXT NOT NULL DEFAULT 'completed',
  risk_score NUMERIC DEFAULT 0,
  confidence_level NUMERIC DEFAULT 50,
  stop_loss NUMERIC,
  take_profit NUMERIC,
  execution_time_ms INTEGER DEFAULT 0,
  reasoning TEXT,
  trade_category VARCHAR(50) DEFAULT 'manual',
  tags TEXT[] DEFAULT '{}',
  notes TEXT,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS on paper trades
ALTER TABLE public.paper_trades ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for paper trades
CREATE POLICY "Users can manage their own paper trades" 
ON public.paper_trades 
FOR ALL 
USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_paper_trades_user_id ON public.paper_trades(user_id);
CREATE INDEX IF NOT EXISTS idx_paper_trades_account_id ON public.paper_trades(account_id);
CREATE INDEX IF NOT EXISTS idx_paper_trades_symbol ON public.paper_trades(symbol);
CREATE INDEX IF NOT EXISTS idx_paper_trades_created_at ON public.paper_trades(created_at);
CREATE INDEX IF NOT EXISTS idx_paper_trades_user_account ON public.paper_trades(user_id, account_id);