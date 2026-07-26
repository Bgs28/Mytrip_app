@extends('admin.layouts.admin')

@section('title', 'Detail Kursi Bus - ' . $seat->seat_code)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.bus-seats.index', ['bus_id' => $seat->bus_id]) }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🪑 Detail Kursi - {{ $seat->seat_code }}</h1>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Info -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Bus Info -->
            <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Bus</p>
                        <p class="text-lg font-semibold">{{ $seat->bus->bus_name ?? '-' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Rute</p>
                        <p class="text-lg">{{ $seat->bus->from ?? '-' }} → {{ $seat->bus->destination ?? '-' }}</p>
                    </div>
                </div>
            </div>

            <!-- Seat Details -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📋 Detail Kursi</h3>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Kode Kursi</p>
                        <p class="text-2xl font-bold text-blue-600">{{ $seat->seat_code }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Nomor Kursi</p>
                        <p class="text-lg font-semibold">{{ $seat->seat_number }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Tipe</p>
                        <p>
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold
                                {{ $seat->seat_type == 'regular' ? 'bg-gray-100 text-gray-700' : 
                                   ($seat->seat_type == 'premium' ? 'bg-blue-100 text-blue-700' : 
                                   'bg-amber-100 text-amber-700') }}">
                                {{ $seat->seat_type_label }}
                            </span>
                        </p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Posisi</p>
                        <p class="font-semibold">{{ $seat->position_label }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Status</p>
                        @if($seat->is_available)
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
                                ✅ Tersedia
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-red-100 text-red-800 text-xs font-semibold">
                                ❌ Tidak Tersedia
                            </span>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Layout Position -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📐 Posisi dalam Layout</h3>
                <div class="flex flex-wrap gap-2">
                    @php
                        $layout = $seat->bus->seat_layout;
                        $found = false;
                    @endphp
                    @foreach($layout as $rowIndex => $row)
                        <div class="flex gap-2">
                            @foreach($row as $colIndex => $s)
                                @if($s && $s['id'] == $seat->id)
                                    <div class="w-14 h-14 flex items-center justify-center text-xs font-bold rounded-lg border-2 border-blue-500 bg-blue-100 text-blue-700 shadow-lg relative">
                                        {{ $s['seat_code'] }}
                                        <div class="absolute -bottom-5 text-[8px] text-blue-600">▼</div>
                                    </div>
                                    @php $found = true; @endphp
                                @elseif($s)
                                    <div class="w-14 h-14 flex items-center justify-center text-xs font-semibold rounded-lg border-2
                                        {{ $s['is_available'] ? 'border-emerald-400 bg-emerald-50 text-emerald-700' : 'border-red-400 bg-red-50 text-red-700' }}">
                                        {{ $s['seat_code'] }}
                                    </div>
                                @else
                                    <div class="w-14 h-14"></div>
                                @endif
                            @endforeach
                        </div>
                    @endforeach
                </div>
                @if(!$found)
                    <p class="text-sm text-gray-400">Kursi tidak ditemukan dalam layout</p>
                @endif
                <div class="mt-3 flex gap-4 text-xs">
                    <span class="flex items-center gap-1">
                        <span class="w-3 h-3 rounded border-2 border-blue-500 bg-blue-100"></span>
                        Kursi Ini (Dipilih)
                    </span>
                    <span class="flex items-center gap-1">
                        <span class="w-3 h-3 rounded border-2 border-emerald-400 bg-emerald-50"></span>
                        Tersedia
                    </span>
                    <span class="flex items-center gap-1">
                        <span class="w-3 h-3 rounded border-2 border-red-400 bg-red-50"></span>
                        Tidak Tersedia
                    </span>
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div class="lg:col-span-1 space-y-6">
            <div class="bg-gray-50 rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">⚙️ Aksi</h3>
                <div class="space-y-3">
                    <form action="{{ route('admin.bus-seats.toggleAvailability', $seat->id) }}" method="POST">
                        @csrf
                        <button type="submit" 
                                class="block w-full {{ $seat->is_available ? 'bg-red-600 hover:bg-red-700' : 'bg-emerald-600 hover:bg-emerald-700' }} text-white font-medium py-2 rounded-lg transition">
                            {{ $seat->is_available ? '❌ Non-Aktifkan' : '✅ Aktifkan' }}
                        </button>
                    </form>
                </div>
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📌 Informasi</h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Dibuat</span>
                        <span>{{ $seat->created_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Diperbarui</span>
                        <span>{{ $seat->updated_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Total Booking</span>
                        <span>{{ $seat->bookingSeats->count() }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection