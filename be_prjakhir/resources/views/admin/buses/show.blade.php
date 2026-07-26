@extends('admin.layouts.admin')

@section('title', 'Detail Bus - ' . $bus->bus_name)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.buses.index') }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🚌 Detail Bus - {{ $bus->bus_name }}</h1>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Info -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Bus Info -->
            <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Nama Bus</p>
                        <p class="text-lg font-semibold">{{ $bus->bus_name }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Rute</p>
                        <p class="text-lg font-semibold">{{ $bus->from }} → {{ $bus->destination }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Harga Tiket</p>
                        <p class="text-lg font-bold text-emerald-600">Rp {{ number_format($bus->price, 0, ',', '.') }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Jumlah Kursi</p>
                        <p class="text-lg font-semibold">{{ $bus->seat }} kursi</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Status</p>
                        @if($bus->status == 'active')
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
                                ✅ Aktif
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-red-100 text-red-800 text-xs font-semibold">
                                ❌ Non-Aktif
                            </span>
                        @endif
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Durasi Perjalanan</p>
                        <p class="text-lg font-semibold">{{ $bus->duration_minutes ?? 120 }} menit</p>
                    </div>
                </div>
            </div>

            <!-- Schedule Info -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📅 Jadwal Keberangkatan</h3>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Periode</p>
                        <p class="font-semibold">
                            {{ date('d M Y', strtotime($bus->start_date)) }} 
                            <span class="text-gray-400">→</span> 
                            {{ date('d M Y', strtotime($bus->end_date)) }}
                        </p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Jam Keberangkatan</p>
                        <div class="flex flex-wrap gap-2 mt-1">
                            @php
                                $times = is_string($bus->departure_times) ? json_decode($bus->departure_times, true) : $bus->departure_times;
                            @endphp
                            @if($times && is_array($times))
                                @foreach($times as $time)
                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-blue-100 text-blue-700 text-xs font-semibold">
                                        {{ $time }}
                                    </span>
                                @endforeach
                            @else
                                <span class="text-gray-400">-</span>
                            @endif
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Schedules -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📊 Statistik</h3>
                <div class="grid grid-cols-3 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Total Kursi</p>
                        <p class="text-2xl font-bold text-blue-600">{{ $bus->seats->count() }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Total Jadwal</p>
                        <p class="text-2xl font-bold text-emerald-600">{{ $bus->schedules->count() }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Jadwal Aktif</p>
                        <p class="text-2xl font-bold text-green-600">{{ $bus->schedules->where('status', 'active')->count() }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div class="lg:col-span-1 space-y-6">
            <div class="bg-gray-50 rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">⚙️ Aksi</h3>
                <div class="space-y-3">
                    <a href="{{ route('admin.buses.edit', $bus->id) }}" 
                       class="block w-full bg-amber-600 hover:bg-amber-700 text-white text-center font-medium py-2 rounded-lg transition">
                        ✏️ Edit Bus
                    </a>
                    <a href="{{ route('admin.bus-seats.index', ['bus_id' => $bus->id]) }}" 
                       class="block w-full bg-purple-600 hover:bg-purple-700 text-white text-center font-medium py-2 rounded-lg transition">
                        🪑 Kelola Kursi
                    </a>
                    <form action="{{ route('admin.buses.destroy', $bus->id) }}" method="POST" 
                          onsubmit="return confirm('Apakah Anda yakin ingin menghapus bus ini? Semua jadwal dan kursi akan terhapus.')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="block w-full bg-red-600 hover:bg-red-700 text-white font-medium py-2 rounded-lg transition">
                            🗑️ Hapus Bus
                        </button>
                    </form>
                </div>
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📌 Informasi</h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Dibuat</span>
                        <span>{{ $bus->created_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Diperbarui</span>
                        <span>{{ $bus->updated_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Total Kursi</span>
                        <span>{{ $bus->seats->count() }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection