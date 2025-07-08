-- Create function to reset paper trading account
CREATE OR REPLACE FUNCTION public.reset_paper_account(account_id_param UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  account_record RECORD;
  initial_balance NUMERIC;
BEGIN
  -- Get account details and verify ownership
  SELECT * INTO account_record 
  FROM public.paper_trading_accounts 
  WHERE id = account_id_param AND user_id = auth.uid();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account not found or access denied';
  END IF;
  
  initial_balance := account_record.initial_balance;
  
  -- Reset account balance
  UPDATE public.paper_trading_accounts 
  SET 
    balance = initial_balance,
    total_pnl = 0,
    total_pnl_percentage = 0,
    updated_at = NOW()
  WHERE id = account_id_param;
  
  -- Create audit entry
  INSERT INTO public.paper_account_audit (
    user_id, account_id, action, old_balance, new_balance, amount_changed, reason
  ) VALUES (
    auth.uid(), account_id_param, 'account_reset', account_record.balance, initial_balance, 
    initial_balance - account_record.balance, 'Account reset to initial balance'
  );
  
  RETURN true;
END;
$$;