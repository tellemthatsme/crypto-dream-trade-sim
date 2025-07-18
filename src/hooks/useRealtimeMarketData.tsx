
import { useState, useEffect, useRef } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useToast } from '@/hooks/use-toast';

interface MarketPrice {
  symbol: string;
  price: number;
  change24h: number;
  volume: number;
  timestamp: number;
}

interface RealtimeData {
  [symbol: string]: MarketPrice;
}

export const useRealtimeMarketData = (symbols: string[] = []) => {
  const [prices, setPrices] = useState<RealtimeData>({});
  const [connectionStatus, setConnectionStatus] = useState<'connecting' | 'connected' | 'disconnected'>('disconnected');
  const [lastUpdate, setLastUpdate] = useState<Date | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const { toast } = useToast();

  const connectWebSocket = () => {
    try {
      setConnectionStatus('connecting');
      
      // Real-time updates every 30 seconds (more reasonable for free APIs)
      const interval = setInterval(async () => {
        try {
          const { data } = await supabase
            .from('market_data_cache')
            .select('symbol, price_usd, change_percentage_24h, volume_24h_usd, last_updated')
            .in('symbol', symbols.length > 0 ? symbols : ['BTC', 'ETH', 'SOL', 'BNB', 'XRP'])
            .order('market_cap_usd', { ascending: false });

          if (data) {
            const newPrices: RealtimeData = {};
            data.forEach(item => {
              // Use real prices without artificial fluctuations
              newPrices[item.symbol] = {
                symbol: item.symbol,
                price: item.price_usd,
                change24h: item.change_percentage_24h,
                volume: item.volume_24h_usd,
                timestamp: Date.now()
              };
            });
            setPrices(newPrices);
            setLastUpdate(new Date());
            setConnectionStatus('connected');

            // Trigger market data refresh every 5 minutes
            if (Date.now() % 300000 < 30000) { // Every 5 minutes
              supabase.functions.invoke('fetch-market-data').catch(console.error);
            }
          }
        } catch (error) {
          console.error('Error fetching realtime data:', error);
          setConnectionStatus('disconnected');
        }
      }, 30000); // 30-second real-time updates

      return () => clearInterval(interval);
    } catch (error) {
      console.error('WebSocket connection error:', error);
      setConnectionStatus('disconnected');
    }
  };

  useEffect(() => {
    const cleanup = connectWebSocket();
    return cleanup;
  }, [symbols.join(',')]);

  // Real-time price alerts with notifications
  const createPriceAlert = (symbol: string, targetPrice: number, direction: 'above' | 'below') => {
    const currentPrice = prices[symbol]?.price;
    if (!currentPrice) return;

    const checkAlert = () => {
      const price = prices[symbol]?.price;
      if (!price) return;

      const triggered = direction === 'above' 
        ? price >= targetPrice 
        : price <= targetPrice;

      if (triggered) {
        toast({
          title: `🚨 Price Alert: ${symbol}`,
          description: `${symbol} hit ${direction} $${targetPrice.toLocaleString()}. Current: $${price.toLocaleString()}`,
          variant: "default",
        });
        
        // Browser notification if permissions granted
        if (Notification.permission === 'granted') {
          new Notification(`🚨 Price Alert: ${symbol}`, {
            body: `${symbol} is now ${direction} $${targetPrice.toLocaleString()}`,
            icon: '/favicon.ico'
          });
        }
      }
    };

    // Monitor for alerts every 30 seconds (matches price update frequency)
    const alertInterval = setInterval(checkAlert, 30000);
    return () => clearInterval(alertInterval);
  };

  return {
    prices,
    connectionStatus,
    lastUpdate,
    isConnected: connectionStatus === 'connected',
    createPriceAlert,
    getPrice: (symbol: string) => prices[symbol]?.price || 0,
    getPriceChange: (symbol: string) => prices[symbol]?.change24h || 0,
  };
};
