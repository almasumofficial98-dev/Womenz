-- ========================================================
-- WOMENZ APP - SUPABASE DATABASE SCHEMA (DDL)
-- Project Reference: vvzwixqkzuypzymqlpvv
-- ========================================================

-- 1. Create PROFILES Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    health_condition TEXT DEFAULT 'regular', -- 'regular', 'irregular', 'pcod_pcos', 'endometriosis', 'perimenopause'
    avg_cycle_length INT DEFAULT 28,
    avg_period_length INT DEFAULT 5,
    cycle_variance INT DEFAULT 3,
    privacy_pin TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create CYCLE_LOGS Table
CREATE TABLE IF NOT EXISTS public.cycle_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    flow_intensity TEXT DEFAULT 'medium', -- 'light', 'medium', 'heavy', 'spotting', 'clot'
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create SYMPTOM_LOGS Table
CREATE TABLE IF NOT EXISTS public.symptom_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    log_date DATE NOT NULL,
    symptoms TEXT[] DEFAULT '{}', -- e.g. {'cramps', 'acne', 'hirsutism', 'bloating', 'sugar_craving', 'fatigue', 'pelvic_pain'}
    moods TEXT[] DEFAULT '{}',    -- e.g. {'happy', 'sensitive', 'anxious', 'irritable', 'calm'}
    water_glasses INT DEFAULT 0,
    sleep_hours NUMERIC(3,1) DEFAULT 0.0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_log_date UNIQUE (user_id, log_date)
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cycle_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_logs ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS Policies
CREATE POLICY "Users can view their own profile" 
ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can manage their cycle logs" 
ON public.cycle_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their symptom logs" 
ON public.symptom_logs FOR ALL USING (auth.uid() = user_id);

-- 6. Trigger to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (new.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
