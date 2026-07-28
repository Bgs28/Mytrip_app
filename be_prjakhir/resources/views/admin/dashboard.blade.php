@extends('admin.layouts.admin')

@section('title', 'Dashboard')

@section('content')
<div class="space-y-6">

    {{-- Header --}}
    <div class="flex items-center justify-between">
        <div>
            <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
            <p class="text-sm text-gray-500 mt-1">Laporan & statistik aplikasi MyTrip — {{ now()->format('d F Y') }}</p>
        </div>
    </div>

    {{-- ── Kartu Statistik Utama ─────────────────────────────────────── --}}
    <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-4">

        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center shrink-0">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase font-medium tracking-wide">Total User</p>
                <p class="text-2xl font-bold text-gray-900">{{ $totalUsers }}</p>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center shrink-0">
                <svg class="w-6 h-6 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase font-medium tracking-wide">Total Booking</p>
                <p class="text-2xl font-bold text-gray-900">{{ $totalBookings }}</p>
                <p class="text-xs text-emerald-600 font-medium">+{{ $bookingsThisMonth }} bulan ini</p>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-violet-50 flex items-center justify-center shrink-0">
                <svg class="w-6 h-6 text-violet-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase font-medium tracking-wide">Total Pendapatan</p>
                <p class="text-xl font-bold text-gray-900">Rp {{ number_format($totalRevenue, 0, ',', '.') }}</p>
                <p class="text-xs text-violet-600 font-medium">Rp {{ number_format($revenueThisMonth, 0, ',', '.') }} bulan ini</p>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-orange-50 flex items-center justify-center shrink-0">
                <svg class="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase font-medium tracking-wide">Menunggu Verifikasi</p>
                <p class="text-2xl font-bold text-gray-900">{{ $bookingPending }}</p>
            </div>
        </div>

    </div>

    {{-- ── Baris Kedua: Armada + Status Booking ─────────────────────────── --}}
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">

        {{-- Armada --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-4">🚌 Data Armada & Properti</p>
            <div class="space-y-3">
                <div class="flex items-center justify-between py-2 border-b border-gray-50">
                    <span class="text-sm text-gray-600">🏨 Hotel</span>
                    <span class="font-bold text-gray-900">{{ $totalHotels }}</span>
                </div>
                <div class="flex items-center justify-between py-2 border-b border-gray-50">
                    <span class="text-sm text-gray-600">🚌 Bus</span>
                    <span class="font-bold text-gray-900">{{ $totalBuses }}</span>
                </div>
                <div class="flex items-center justify-between py-2">
                    <span class="text-sm text-gray-600">🚆 Kereta</span>
                    <span class="font-bold text-gray-900">{{ $totalTrains }}</span>
                </div>
            </div>
        </div>

        {{-- Status Booking --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-4">📊 Status Booking</p>
            <div class="space-y-3">
                @php
                    $total = max($bookingPending + $bookingPaid + $bookingCancelled, 1);
                @endphp
                <div>
                    <div class="flex justify-between text-xs text-gray-600 mb-1">
                        <span>Pending</span><span class="font-semibold">{{ $bookingPending }}</span>
                    </div>
                    <div class="w-full bg-gray-100 rounded-full h-2">
                        <div class="bg-yellow-400 h-2 rounded-full" style="width: {{ round($bookingPending/$total*100) }}%"></div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between text-xs text-gray-600 mb-1">
                        <span>Paid</span><span class="font-semibold">{{ $bookingPaid }}</span>
                    </div>
                    <div class="w-full bg-gray-100 rounded-full h-2">
                        <div class="bg-emerald-500 h-2 rounded-full" style="width: {{ round($bookingPaid/$total*100) }}%"></div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between text-xs text-gray-600 mb-1">
                        <span>Cancelled</span><span class="font-semibold">{{ $bookingCancelled }}</span>
                    </div>
                    <div class="w-full bg-gray-100 rounded-full h-2">
                        <div class="bg-red-400 h-2 rounded-full" style="width: {{ round($bookingCancelled/$total*100) }}%"></div>
                    </div>
                </div>
            </div>
        </div>

        {{-- Booking per Tipe --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-4">🗂 Booking per Tipe</p>
            <div class="space-y-3">
                @php
                    $typeIcons = ['bus' => '🚌', 'train' => '🚆', 'hotel' => '🏨'];
                    $typeColors = ['bus' => 'bg-blue-500', 'train' => 'bg-indigo-500', 'hotel' => 'bg-emerald-500'];
                    $typeTotal = max($bookingByType->sum(), 1);
                @endphp
                @foreach(['bus','train','hotel'] as $t)
                    @php $count = $bookingByType[$t] ?? 0; @endphp
                    <div>
                        <div class="flex justify-between text-xs text-gray-600 mb-1">
                            <span>{{ $typeIcons[$t] }} {{ ucfirst($t) }}</span>
                            <span class="font-semibold">{{ $count }}</span>
                        </div>
                        <div class="w-full bg-gray-100 rounded-full h-2">
                            <div class="{{ $typeColors[$t] }} h-2 rounded-full" style="width: {{ round($count/$typeTotal*100) }}%"></div>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>

    </div>

    {{-- ── Grafik Pendapatan & Booking Bulanan ───────────────────────────── --}}
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

        {{-- Pendapatan 12 Bulan --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-4">💰 Pendapatan 12 Bulan Terakhir</p>
            @php $maxRev = max(max(array_column($revenueMonthly, 'amount')), 1); @endphp
            <div class="flex items-end gap-1 h-36">
                @foreach($revenueMonthly as $rm)
                    @php $pct = round($rm['amount'] / $maxRev * 100); @endphp
                    <div class="flex-1 flex flex-col items-center gap-1 group relative">
                        <div class="w-full bg-violet-500 rounded-t-sm transition-all"
                             style="height: {{ max($pct, 2) }}%"
                             title="{{ $rm['label'] }}: Rp {{ number_format($rm['amount'],0,',','.') }}">
                        </div>
                        <span class="text-[9px] text-gray-400 writing-mode-vertical hidden lg:block truncate" style="writing-mode:vertical-rl;transform:rotate(180deg);max-height:40px">{{ $rm['label'] }}</span>
                    </div>
                @endforeach
            </div>
            <div class="mt-2 flex justify-between text-xs text-gray-400">
                <span>{{ $revenueMonthly[0]['label'] }}</span>
                <span>{{ $revenueMonthly[count($revenueMonthly)-1]['label'] }}</span>
            </div>
        </div>

        {{-- Booking 6 Bulan --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-4">📋 Booking 6 Bulan Terakhir</p>
            @php $maxBook = max(max(array_column($bookingMonthly, 'total')), 1); @endphp
            <div class="flex items-end gap-2 h-36">
                @foreach($bookingMonthly as $bm)
                    @php $pct = round($bm['total'] / $maxBook * 100); @endphp
                    <div class="flex-1 flex flex-col items-center gap-1">
                        <span class="text-xs font-semibold text-gray-700">{{ $bm['total'] }}</span>
                        <div class="w-full bg-emerald-500 rounded-t-sm"
                             style="height: {{ max($pct, 2) }}%">
                        </div>
                        <span class="text-[10px] text-gray-400 text-center leading-tight">{{ $bm['label'] }}</span>
                    </div>
                @endforeach
            </div>
        </div>

    </div>

    {{-- ── Pembayaran Menunggu Verifikasi ────────────────────────────────── --}}
    @if($pendingPayments->count())
    <div class="bg-white rounded-2xl shadow-sm border border-orange-100 p-5">
        <div class="flex items-center justify-between mb-4">
            <p class="text-sm font-semibold text-gray-700">⏳ Bukti Pembayaran — Menunggu Verifikasi</p>
            <a href="{{ route('admin.booking.index') }}" class="text-xs text-blue-600 hover:underline">Lihat Semua</a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="text-left text-xs text-gray-500 border-b">
                        <th class="pb-2 pr-4">Kode Booking</th>
                        <th class="pb-2 pr-4">User</th>
                        <th class="pb-2 pr-4">Invoice</th>
                        <th class="pb-2 pr-4">Total</th>
                        <th class="pb-2 pr-4">Tipe</th>
                        <th class="pb-2">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @foreach($pendingPayments as $pay)
                    <tr class="hover:bg-gray-50">
                        <td class="py-2 pr-4 font-mono text-xs font-semibold text-blue-700">
                            {{ $pay->booking->booking_code ?? '-' }}
                        </td>
                        <td class="py-2 pr-4">{{ $pay->booking->user->name ?? '-' }}</td>
                        <td class="py-2 pr-4 font-mono text-xs">{{ $pay->invoice_number }}</td>
                        <td class="py-2 pr-4 font-semibold text-emerald-700">
                            Rp {{ number_format($pay->total_amount, 0, ',', '.') }}
                        </td>
                        <td class="py-2 pr-4">
                            <span class="px-2 py-0.5 rounded-full text-xs font-medium
                                {{ $pay->booking->type == 'hotel' ? 'bg-emerald-100 text-emerald-700' :
                                   ($pay->booking->type == 'bus' ? 'bg-blue-100 text-blue-700' : 'bg-indigo-100 text-indigo-700') }}">
                                {{ strtoupper($pay->booking->type ?? '-') }}
                            </span>
                        </td>
                        <td class="py-2">
                            <a href="{{ route('admin.booking.show', $pay->booking_id) }}"
                               class="text-xs bg-blue-600 text-white px-3 py-1 rounded-lg hover:bg-blue-700">
                                Verifikasi
                            </a>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @endif

    {{-- ── Booking Terbaru ───────────────────────────────────────────────── --}}
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
        <div class="flex items-center justify-between mb-4">
            <p class="text-sm font-semibold text-gray-700">🕐 Booking Terbaru</p>
            <a href="{{ route('admin.booking.index') }}" class="text-xs text-blue-600 hover:underline">Lihat Semua</a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="text-left text-xs text-gray-500 border-b">
                        <th class="pb-2 pr-4">Kode</th>
                        <th class="pb-2 pr-4">User</th>
                        <th class="pb-2 pr-4">Tipe</th>
                        <th class="pb-2 pr-4">Total</th>
                        <th class="pb-2 pr-4">Tanggal</th>
                        <th class="pb-2">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @foreach($recentBookings as $b)
                    <tr class="hover:bg-gray-50">
                        <td class="py-2 pr-4">
                            <a href="{{ route('admin.booking.show', $b->id) }}"
                               class="font-mono text-xs font-semibold text-blue-700 hover:underline">
                                {{ $b->booking_code }}
                            </a>
                        </td>
                        <td class="py-2 pr-4 text-gray-700">{{ $b->user->name ?? '-' }}</td>
                        <td class="py-2 pr-4">
                            <span class="px-2 py-0.5 rounded-full text-xs font-medium
                                {{ $b->type == 'hotel' ? 'bg-emerald-100 text-emerald-700' :
                                   ($b->type == 'bus' ? 'bg-blue-100 text-blue-700' : 'bg-indigo-100 text-indigo-700') }}">
                                {{ strtoupper($b->type) }}
                            </span>
                        </td>
                        <td class="py-2 pr-4 font-semibold">
                            Rp {{ number_format($b->total_price, 0, ',', '.') }}
                        </td>
                        <td class="py-2 pr-4 text-gray-500 text-xs">
                            {{ $b->created_at->format('d M Y H:i') }}
                        </td>
                        <td class="py-2">
                            @php
                                $statusClass = match($b->status) {
                                    'paid'   => 'bg-emerald-100 text-emerald-700',
                                    'pending'=> 'bg-yellow-100 text-yellow-700',
                                    'cancel' => 'bg-red-100 text-red-600',
                                    default  => 'bg-gray-100 text-gray-600',
                                };
                                $statusLabel = match($b->status) {
                                    'paid'   => 'Paid',
                                    'pending'=> 'Pending',
                                    'cancel' => 'Cancelled',
                                    default  => $b->status,
                                };
                            @endphp
                            <span class="px-2 py-0.5 rounded-full text-xs font-medium {{ $statusClass }}">
                                {{ $statusLabel }}
                            </span>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    {{-- ── Hotel Teratas ─────────────────────────────────────────────────── --}}
    @if($topHotels->count())
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
        <p class="text-sm font-semibold text-gray-700 mb-4">🏨 Hotel dengan Kamar Terbanyak</p>
        <div class="space-y-3">
            @foreach($topHotels as $h)
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-lg overflow-hidden bg-gray-100 shrink-0">
                        @if($h->image_url)
                            <img src="{{ $h->image_url }}" class="w-full h-full object-cover"
                                 onerror="this.style.display='none'">
                        @endif
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-800">{{ $h->name }}</p>
                        <p class="text-xs text-gray-500">{{ $h->location }}</p>
                    </div>
                </div>
                <div class="text-right">
                    <p class="text-sm font-bold text-gray-900">{{ $h->rooms_count }} kamar</p>
                    @if($h->rating)
                        <p class="text-xs text-yellow-500">⭐ {{ number_format($h->rating, 1) }}</p>
                    @endif
                </div>
            </div>
            @endforeach
        </div>
    </div>
    @endif

</div>
@endsection
