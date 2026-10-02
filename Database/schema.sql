CREATE TABLE hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    hospital_load INTEGER DEFAULT 0,
    facilities JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.hospitals
ENABLE ROW LEVEL SECURITY;


CREATE TABLE public.beds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    hospital_id UUID NOT NULL
        REFERENCES public.hospitals(id)
        ON DELETE CASCADE,

    bed_type VARCHAR(50) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'available'
        CHECK (status IN ('available', 'reserved', 'occupied')),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.beds
ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.ambulance_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    ambulance_id VARCHAR(100) NOT NULL,

    bed_type VARCHAR(50) NOT NULL,

    required_facilities JSONB
        DEFAULT '[]'::jsonb,

    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',
            'matched',
            'completed',
            'cancelled'
        )),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.ambulance_requests
ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    request_id UUID NOT NULL
        REFERENCES public.ambulance_requests(id),

    hospital_id UUID NOT NULL
        REFERENCES public.hospitals(id),

    bed_id UUID NOT NULL
        REFERENCES public.beds(id),

    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',
            'accepted',
            'rejected',
            'expired',
            'cancelled'
        )),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expires_at TIMESTAMPTZ NOT NULL
        DEFAULT (NOW() + INTERVAL '2 minutes'),

    responded_at TIMESTAMPTZ
);

ALTER TABLE public.reservations
ENABLE ROW LEVEL SECURITY;