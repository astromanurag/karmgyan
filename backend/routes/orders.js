const express = require('express');
const router = express.Router();

let supabase;
try {
  const { createClient } = require('@supabase/supabase-js');
  if (process.env.SUPABASE_URL && process.env.SUPABASE_ANON_KEY) {
    supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
  }
} catch (error) {
  console.warn('Supabase not configured, using mock mode');
}

router.get('/', async (req, res) => {
  try {
    if (supabase) {
      const { data, error } = await supabase
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      res.json(data);
    } else {
      // Mock data
      res.json([]);
    }
  } catch (error) {
    console.error('Orders error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const order = req.body;
    
    if (supabase) {
      const { data, error } = await supabase
        .from('orders')
        .insert([order])
        .select()
        .single();
      
      if (error) throw error;
      res.json(data);
    } else {
      // Mock response
      res.json({ ...order, id: `order_${Date.now()}` });
    }
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

