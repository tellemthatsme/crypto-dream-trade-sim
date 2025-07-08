-- Create AI trading bots table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.ai_trading_bots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  strategy TEXT NOT NULL,
  ai_model TEXT NOT NULL DEFAULT 'deepseek-r1',
  target_symbols TEXT[] NOT NULL,
  status TEXT NOT NULL DEFAULT 'paused' CHECK (status IN ('active', 'paused', 'stopped', 'error')),
  mode TEXT NOT NULL DEFAULT 'paper' CHECK (mode IN ('paper', 'live')),
  paper_balance NUMERIC DEFAULT 10000.00,
  paper_account_id UUID REFERENCES public.paper_trading_accounts(id),
  max_position_size NUMERIC DEFAULT 1000.00,
  risk_level TEXT NOT NULL DEFAULT 'medium',
  config JSONB DEFAULT '{}'::jsonb,
  performance JSONB DEFAULT '{}'::jsonb,
  last_trade_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on AI trading bots
ALTER TABLE public.ai_trading_bots ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for AI trading bots
CREATE POLICY "Users can manage their own AI trading bots" 
ON public.ai_trading_bots 
FOR ALL 
USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_ai_trading_bots_user_id ON public.ai_trading_bots(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_trading_bots_status ON public.ai_trading_bots(status);
CREATE INDEX IF NOT EXISTS idx_ai_trading_bots_account_id ON public.ai_trading_bots(paper_account_id);

-- Enable realtime for AI trading bots
ALTER PUBLICATION supabase_realtime ADD TABLE public.ai_trading_bots;
ALTER TABLE public.ai_trading_bots REPLICA IDENTITY FULL;