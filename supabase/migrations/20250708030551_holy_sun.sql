-- Create paper trading accounts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.paper_trading_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  account_name TEXT NOT NULL,
  balance NUMERIC DEFAULT 100000.00,
  initial_balance NUMERIC DEFAULT 100000.00,
  total_pnl NUMERIC DEFAULT 0.00,
  total_pnl_percentage NUMERIC DEFAULT 0.00,
  is_default BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on paper trading accounts
ALTER TABLE public.paper_trading_accounts ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for paper trading accounts
CREATE POLICY "Users can manage their own paper trading accounts" 
ON public.paper_trading_accounts 
FOR ALL 
USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_paper_trading_accounts_user_id ON public.paper_trading_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_paper_trading_accounts_is_default ON public.paper_trading_accounts(is_default);

-- Create trigger for updated_at
CREATE TRIGGER update_paper_trading_accounts_updated_at
BEFORE UPDATE ON public.paper_trading_accounts
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();