
import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import { useRealTimePortfolio } from '@/hooks/useRealTimePortfolio';
import { useMultipleAccounts } from '@/hooks/useMultipleAccounts';
import { TradeSignalCard, TradeSignal } from './TradeSignal';
import { TradeFollowingSettings } from './TradeFollowingSettings';
import { ActiveAccountDisplay } from './ActiveAccountDisplay';
import { Users } from 'lucide-react';

export const TradeFollower = () => {
  const { trades } = useRealTimePortfolio();
  const { currentAccount, executeTrade } = useMultipleAccounts();
  const [isFollowing, setIsFollowing] = useState(false);
  const [signals, setSignals] = useState<TradeSignal[]>([]);
  const [followSettings, setFollowSettings] = useState({
    minConfidence: 70,
    maxPositionSize: 1000,
    autoExecute: false
  });

  // Convert trades to the expected format for TradeTooltip
  const formattedTrades = trades.map(trade => ({
    ...trade,
    side: (trade.side === 'buy' || trade.side === 'sell') ? trade.side : 'buy' as 'buy' | 'sell'
  }));

  // Simulate incoming trade signals with real market movements
  useEffect(() => {
    if (!isFollowing) return;

    const interval = setInterval(() => {
      const symbols = ['BTC', 'ETH', 'SOL', 'ADA', 'DOT', 'LINK'];
      const sides: ('buy' | 'sell')[] = ['buy', 'sell'];
      
      const newSignal: TradeSignal = {
        id: Date.now().toString(),
        symbol: symbols[Math.floor(Math.random() * symbols.length)],
        side: sides[Math.floor(Math.random() * sides.length)],
        price: 50000 + Math.random() * 20000,
        amount: 0.01 + Math.random() * 0.1,
        confidence: 60 + Math.random() * 40,
        source: 'AI Analysis',
        timestamp: new Date().toISOString()
      };

      setSignals(prev => [newSignal, ...prev.slice(0, 9)]); // Keep last 10 signals

      // Auto-execute if enabled and confidence is high enough
      if (followSettings.autoExecute && newSignal.confidence >= followSettings.minConfidence) {
        handleFollowTrade(newSignal);
      }
    }, 8000); // New signal every 8 seconds for better real-time feel

    return () => clearInterval(interval);
  }, [isFollowing, followSettings]);

  const handleFollowTrade = async (signal: TradeSignal) => {
    if (!currentAccount) return;

    const success = await executeTrade({
      symbol: signal.symbol,
      side: signal.side,
      amount: Math.min(signal.amount, followSettings.maxPositionSize / signal.price),
      price: signal.price,
      type: 'market'
    });

    if (success) {
      console.log('Trade followed successfully:', signal);
      // Remove the signal after execution to show it was processed
      setSignals(prev => prev.filter(s => s.id !== signal.id));
    }
  };

  const handleToggleFollowing = (enabled: boolean) => {
    console.log('Toggle following:', enabled);
    setIsFollowing(enabled);
    if (!enabled) {
      console.log('Stopping trade following, clearing signals');
      setSignals([]);
    } else {
      console.log('Starting trade following');
    }
  };

  return (
    <Card className="crypto-card-gradient text-white">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Users className="w-5 h-5" />
          Trade Following System
          <Badge className={`ml-auto ${isFollowing ? 'bg-green-500/20 text-green-400' : 'bg-gray-500/20 text-gray-400'}`}>
            {isFollowing ? 'Active' : 'Inactive'}
          </Badge>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between p-3 bg-white/5 rounded">
          <span>Enable Trade Following</span>
          <Switch checked={isFollowing} onCheckedChange={handleToggleFollowing} />
        </div>

        {isFollowing && (
          <>
          <TradeFollowingSettings 
            settings={followSettings}
            onSettingsChange={setFollowSettings}
          />

            <div className="space-y-2">
              <h4 className="font-medium flex items-center gap-2">
                Live Trading Signals
                <Badge variant="outline" className="text-xs">
                  {signals.length}
                </Badge>
              </h4>
              
              <div className="max-h-60 overflow-y-auto space-y-2">
                {signals.length === 0 ? (
                  <div className="text-center py-4 text-white/60">
                    Waiting for trading signals...
                  </div>
                ) : (
                  signals.map((signal) => (
                    <TradeSignalCard
                      key={signal.id}
                      signal={signal}
                      trades={formattedTrades}
                      onFollow={handleFollowTrade}
                      minConfidence={followSettings.minConfidence}
                    />
                  ))
                )}
              </div>
            </div>

            <ActiveAccountDisplay account={currentAccount} />
          </>
        )}
      </CardContent>
    </Card>
  );
};
