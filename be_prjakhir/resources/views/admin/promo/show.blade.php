@extends('admin.layouts.admin')

@section('title', 'Detail Promo - ' . $promo->code)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.promo.index') }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🎫 Detail Promo</h1>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Info Utama -->
        <div class="lg:col-span-2 space-y-6">
            <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Kode Promo</p>
                        <p class="text-2xl font-bold text-blue-600">{{ $promo->code }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Nama</p>
                        <p class="text-lg font-semibold">{{ $promo->name }}</p>
                    </div>
                </div>
                @if($promo->description)
                    <div class="mt-4">
                        <p class="text-sm text-gray-500">Deskripsi</p>
                        <p class="text-sm">{{ $promo->description }}</p>
                    </div>
                @endif
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📊 Detail Diskon</h3>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Tipe Diskon</p>
                        <p class="font-medium">{{ $promo->discount_type == 'percentage' ? 'Persentase (%)' : 'Nominal (Rp)' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Nilai Diskon</p>
                        <p class="font-medium text-emerald-600">
                            @if($promo->discount_type == 'percentage')
                                {{ $promo->discount_value }}%
                            @else
                                Rp {{ number_format($promo->discount_value, 0, ',', '.') }}
                            @endif
                        </p>
                    </div>
                    @if($promo->max_discount)
                        <div>
                            <p class="text-sm text-gray-500">Maksimal Diskon</p>
                            <p class="font-medium">Rp {{ number_format($promo->max_discount, 0, ',', '.') }}</p>
                        </div>
                    @endif
                    <div>
                        <p class="text-sm text-gray-500">Minimal Pembelian</p>
                        <p class="font-medium">Rp {{ number_format($promo->min_purchase, 0, ',', '.') }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📅 Periode</h3>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Mulai</p>
                        <p class="font-medium">{{ date('d M Y H:i', strtotime($promo->start_date)) }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Berakhir</p>
                        <p class="font-medium">{{ date('d M Y H:i', strtotime($promo->end_date)) }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📈 Statistik Penggunaan</h3>
                <div class="grid grid-cols-3 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Total Penggunaan</p>
                        <p class="text-2xl font-bold text-blue-600">{{ $promo->usage_count }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Batas Penggunaan</p>
                        <p class="text-2xl font-bold">{{ $promo->usage_limit ?? '∞' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Sisa</p>
                        <p class="text-2xl font-bold text-emerald-600">
                            {{ $promo->usage_limit ? $promo->usage_limit - $promo->usage_count : '∞' }}
                        </p>
                    </div>
                </div>
            </div>

            <!-- Booking yang menggunakan promo -->
            @if($promo->bookings->count() > 0)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-4">📋 Booking yang Menggunakan Promo</h3>
                    <div class="space-y-2">
                        @foreach($promo->bookings->take(5) as $booking)
                            <div class="flex justify-between items-center p-2 bg-gray-50 rounded">
                                <span class="text-sm">{{ $booking->booking_code }}</span>
                                <span class="text-sm text-gray-500">
                                    {{ date('d M Y', strtotime($booking->created_at)) }}
                                </span>
                            </div>
                        @endforeach
                        @if($promo->bookings->count() > 5)
                            <p class="text-sm text-gray-400">... dan {{ $promo->bookings->count() - 5 }} booking lainnya</p>
                        @endif
                    </div>
                </div>
            @endif
        </div>

        <!-- Sidebar -->
        <div class="lg:col-span-1 space-y-6">
            <div class="bg-gray-50 rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">⚙️ Aksi</h3>
                <div class="space-y-3">
                    <a href="{{ route('admin.promo.edit', $promo->id) }}" 
                       class="block w-full bg-amber-600 hover:bg-amber-700 text-white text-center font-medium py-2 rounded-lg transition">
                        ✏️ Edit Promo
                    </a>
                    <form action="{{ route('admin.promo.toggleActive', $promo->id) }}" method="POST">
                        @csrf
                        <button type="submit" 
                                class="block w-full {{ $promo->is_active ? 'bg-red-600 hover:bg-red-700' : 'bg-emerald-600 hover:bg-emerald-700' }} text-white font-medium py-2 rounded-lg transition">
                            {{ $promo->is_active ? '❌ Non-Aktifkan' : '✅ Aktifkan' }}
                        </button>
                    </form>
                    <form action="{{ route('admin.promo.destroy', $promo->id) }}" method="POST" 
                          onsubmit="return confirm('Apakah Anda yakin ingin menghapus promo ini?')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="block w-full bg-red-600 hover:bg-red-700 text-white font-medium py-2 rounded-lg transition">
                            🗑️ Hapus Promo
                        </button>
                    </form>
                </div>
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📌 Status</h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Status</span>
                        @php
                            $isActive = $promo->is_active && $promo->start_date <= now() && $promo->end_date >= now();
                        @endphp
                        @if($isActive)
                            <span class="text-emerald-600 font-semibold">✅ Aktif</span>
                        @elseif($promo->end_date < now())
                            <span class="text-gray-500 font-semibold">⏰ Kadaluarsa</span>
                        @else
                            <span class="text-red-600 font-semibold">❌ Non-Aktif</span>
                        @endif
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Target</span>
                        <span>{{ $promo->target_type == 'all' ? 'Semua' : strtoupper($promo->target_type) }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Dibuat</span>
                        <span>{{ date('d M Y H:i', strtotime($promo->created_at)) }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Diperbarui</span>
                        <span>{{ date('d M Y H:i', strtotime($promo->updated_at)) }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection