import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id } = await req.json()
    
    if (!user_id) {
      throw new Error('User ID is required')
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Default bot configurations
    const defaultBots = [
      { name: "Bitcoin Trend Master", strategy: "trend-following", symbols: ["BTC"], risk: "medium" },
      { name: "Ethereum Grid Bot", strategy: "grid-trading", symbols: ["ETH"], risk: "low" },
      { name: "Multi-Coin DCA", strategy: "dca", symbols: ["BTC", "ETH", "SOL"], risk: "low" },
      { name: "Solana Breakout Hunter", strategy: "breakout", symbols: ["SOL"], risk: "high" },
      { name: "Arbitrage Scanner", strategy: "arbitrage", symbols: ["BTC", "ETH"], risk: "medium" },
      { name: "Momentum Trader", strategy: "momentum", symbols: ["ADA", "DOT"], risk: "high" },
      { name: "Mean Reversion Bot", strategy: "mean-reversion", symbols: ["LINK", "UNI"], risk: "medium" },
      { name: "Scalping Master", strategy: "scalping", symbols: ["BTC"], risk: "aggressive" },
      { name: "News Sentiment Trader", strategy: "sentiment", symbols: ["BTC", "ETH", "SOL"], risk: "medium" },
      { name: "ML Prediction Engine", strategy: "ml-prediction", symbols: ["BTC", "ETH"], risk: "high" },
      { name: "Cross-Exchange Arb", strategy: "arbitrage", symbols: ["BTC", "ETH", "USDT"], risk: "low" },
      { name: "Whale Tracker", strategy: "on-chain", symbols: ["BTC", "ETH"], risk: "medium" },
      { name: "Options Hedge Bot", strategy: "hedge", symbols: ["BTC", "ETH"], risk: "medium" },
      { name: "Flash Crash Hunter", strategy: "contrarian", symbols: ["BTC", "ETH", "SOL"], risk: "aggressive" },
      { name: "Pairs Trading Bot", strategy: "pairs", symbols: ["BTC", "ETH"], risk: "medium" },
      { name: "Futures Spreader", strategy: "spread", symbols: ["BTC", "ETH"], risk: "high" },
      { name: "Stablecoin Yield", strategy: "yield", symbols: ["USDT", "USDC", "DAI"], risk: "low" },
      { name: "Altcoin Rotation", strategy: "rotation", symbols: ["ADA", "DOT", "LINK", "UNI"], risk: "high" },
      { name: "Technical Pattern Bot", strategy: "pattern", symbols: ["BTC", "ETH"], risk: "medium" },
      { name: "Volume Surge Detector", strategy: "volume", symbols: ["BTC", "ETH", "SOL", "ADA"], risk: "high" }
    ]

    // Get default account for the user
    const { data: accounts, error: accountError } = await supabaseClient
      .from('paper_trading_accounts')
      .select('id')
      .eq('user_id', user_id)
      .eq('is_default', true)
      .limit(1)

    if (accountError) throw accountError
    
    const defaultAccountId = accounts && accounts.length > 0 ? accounts[0].id : null

    // Create bots
    const botInserts = defaultBots.map(bot => ({
      user_id: user_id,
      name: bot.name,
      strategy: bot.strategy,
      ai_model: 'deepseek-r1',
      target_symbols: bot.symbols,
      status: 'paused',
      mode: 'paper',
      paper_balance: 10000,
      max_position_size: 1000,
      risk_level: bot.risk,
      paper_account_id: defaultAccountId,
      config: {
        maxPositionSize: 1000,
        riskLevel: bot.risk
      },
      performance: {
        total_return: 0,
        win_rate: 0,
        total_trades: 0,
        daily_pnl: 0,
        weekly_pnl: 0,
        monthly_pnl: 0
      }
    }))

    const { error: insertError } = await supabaseClient
      .from('ai_trading_bots')
      .insert(botInserts)

    if (insertError) throw insertError

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `Created ${botInserts.length} trading bots for user ${user_id}`,
        count: botInserts.length
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error creating initial trading bots:', error)
    return new Response(
      JSON.stringify({ 
        error: error.message,
        success: false 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})