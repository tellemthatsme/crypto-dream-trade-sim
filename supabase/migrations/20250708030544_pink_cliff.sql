-- Create paper account audit table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.paper_account_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  account_id UUID NOT NULL REFERENCES public.paper_trading_accounts(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  old_balance NUMERIC,
  new_balance NUMERIC,
  amount_changed NUMERIC,
  reason TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  session_id VARCHAR(100),
  device_info TEXT,
  location_info JSONB DEFAULT '{}'::jsonb,
  transaction_hash VARCHAR(100),
  related_trade_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on paper account audit
ALTER TABLE public.paper_account_audit ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for paper account audit
CREATE POLICY "Users can view their own account audit" 
ON public.paper_account_audit 
FOR SELECT 
USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_paper_account_audit_account_id ON public.paper_account_audit(account_id);
CREATE INDEX IF NOT EXISTS idx_paper_account_audit_user_id ON public.paper_account_audit(user_id);
CREATE INDEX IF NOT EXISTS idx_paper_account_audit_created_at ON public.paper_account_audit(created_at);