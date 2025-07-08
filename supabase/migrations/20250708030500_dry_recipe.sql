-- Create function to initialize trading bots for new users
CREATE OR REPLACE FUNCTION public.create_initial_trading_bots(user_id_param UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  default_account_id UUID;
  bot_config JSONB;
  bot_performance JSONB;
  bot_record RECORD;
BEGIN
  -- Get default account for the user
  SELECT id INTO default_account_id
  FROM public.paper_trading_accounts
  WHERE user_id = user_id_param AND is_default = true
  LIMIT 1;

  -- Default bot configurations
  FOR bot_record IN (
    SELECT * FROM (VALUES
      ('Bitcoin Trend Master', 'trend-following', ARRAY['BTC']::TEXT[], 'medium'),
      ('Ethereum Grid Bot', 'grid-trading', ARRAY['ETH']::TEXT[], 'low'),
      ('Multi-Coin DCA', 'dca', ARRAY['BTC', 'ETH', 'SOL']::TEXT[], 'low'),
      ('Solana Breakout Hunter', 'breakout', ARRAY['SOL']::TEXT[], 'high'),
      ('Arbitrage Scanner', 'arbitrage', ARRAY['BTC', 'ETH']::TEXT[], 'medium'),
      ('Momentum Trader', 'momentum', ARRAY['ADA', 'DOT']::TEXT[], 'high'),
      ('Mean Reversion Bot', 'mean-reversion', ARRAY['LINK', 'UNI']::TEXT[], 'medium'),
      ('Scalping Master', 'scalping', ARRAY['BTC']::TEXT[], 'high'),
      ('News Sentiment Trader', 'sentiment', ARRAY['BTC', 'ETH', 'SOL']::TEXT[], 'medium'),
      ('ML Prediction Engine', 'ml-prediction', ARRAY['BTC', 'ETH']::TEXT[], 'high'),
      ('Cross-Exchange Arb', 'arbitrage', ARRAY['BTC', 'ETH', 'USDT']::TEXT[], 'low'),
      ('Whale Tracker', 'on-chain', ARRAY['BTC', 'ETH']::TEXT[], 'medium'),
      ('Options Hedge Bot', 'hedge', ARRAY['BTC', 'ETH']::TEXT[], 'medium'),
      ('Flash Crash Hunter', 'contrarian', ARRAY['BTC', 'ETH', 'SOL']::TEXT[], 'high'),
      ('Pairs Trading Bot', 'pairs', ARRAY['BTC', 'ETH']::TEXT[], 'medium'),
      ('Futures Spreader', 'spread', ARRAY['BTC', 'ETH']::TEXT[], 'high'),
      ('Stablecoin Yield', 'yield', ARRAY['USDT', 'USDC', 'DAI']::TEXT[], 'low'),
      ('Altcoin Rotation', 'rotation', ARRAY['ADA', 'DOT', 'LINK', 'UNI']::TEXT[], 'high'),
      ('Technical Pattern Bot', 'pattern', ARRAY['BTC', 'ETH']::TEXT[], 'medium'),
      ('Volume Surge Detector', 'volume', ARRAY['BTC', 'ETH', 'SOL', 'ADA']::TEXT[], 'high')
    ) AS t(name, strategy, symbols, risk)
  ) LOOP
    -- Create bot config
    bot_config := jsonb_build_object(
      'maxPositionSize', 1000,
      'riskLevel', bot_record.risk
    );
    
    -- Create bot performance
    bot_performance := jsonb_build_object(
      'total_return', 0,
      'win_rate', 0,
      'total_trades', 0,
      'daily_pnl', 0,
      'weekly_pnl', 0,
      'monthly_pnl', 0
    );
    
    -- Insert bot
    INSERT INTO public.ai_trading_bots (
      user_id, name, strategy, ai_model, target_symbols, status, mode,
      paper_balance, max_position_size, risk_level, paper_account_id,
      config, performance
    ) VALUES (
      user_id_param, bot_record.name, bot_record.strategy, 'deepseek-r1',
      bot_record.symbols, 'paused', 'paper', 10000, 1000, bot_record.risk,
      default_account_id, bot_config, bot_performance
    );
  END LOOP;
END;
$$;