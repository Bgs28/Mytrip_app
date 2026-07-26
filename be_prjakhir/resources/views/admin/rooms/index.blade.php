@extends('admin.layouts.admin')

@section('title', 'Kelola Kamar Hotel')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">🛏️ Kelola Kamar Hotel</h1>
            <p class="text-sm text-gray-500 mt-1">
                @if($hotel)
                    Kamar untuk hotel: <span class="font-semibold text-gray-700">{{ $hotel->name }}</span>
                @else
                    Kelola semua kamar hotel
                @endif
            </p>
        </div>
        <a href="{{ route('admin.rooms.create', ['hotel_id' => $hotel?->id]) }}" 
           class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
            </svg>
            Tambah Kamar
        </a>
    </div>

    <!-- Alert Messages -->
    @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    @if(session('error'))
        <div class="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            {{ session('error') }}
        </div>
    @endif

    <!-- Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-6">
        <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
            <p class="text-sm text-blue-600">Total Kamar</p>
            <p class="text-2xl font-bold text-blue-700">{{ $rooms->total() }}</p>
        </div>
        <div class="bg-emerald-50 rounded-lg p-4 border border-emerald-100">
            <p class="text-sm text-emerald-600">Tersedia</p>
            <p class="text-2xl font-bold text-emerald-700">{{ $rooms->where('is_available', true)->count() }}</p>
        </div>
        <div class="bg-red-50 rounded-lg p-4 border border-red-100">
            <p class="text-sm text-red-600">Tidak Tersedia</p>
            <p class="text-2xl font-bold text-red-700">{{ $rooms->where('is_available', false)->count() }}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
            <p class="text-sm text-purple-600">Tipe Kamar</p>
            <p class="text-2xl font-bold text-purple-700">{{ $rooms->pluck('room_type')->unique()->count() }}</p>
        </div>
    </div>

    <!-- Filter -->
    <div class="mb-6">
        <form method="GET" action="{{ route('admin.rooms.index') }}" class="flex flex-wrap gap-3">
            @if($hotel)
                <input type="hidden" name="hotel_id" value="{{ $hotel->id }}">
            @endif
            <div class="flex-1 min-w-[200px]">
                <input type="text" name="search" value="{{ request('search') }}" 
                       placeholder="Cari nomor atau nama kamar..." 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
            </div>
            <select name="type" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Tipe</option>
                @foreach($roomTypes as $type)
                    <option value="{{ $type }}" {{ request('type') == $type ? 'selected' : '' }}>
                        {{ ucfirst($type) }}
                    </option>
                @endforeach
            </select>
            <select name="availability" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Status</option>
                <option value="available" {{ request('availability') == 'available' ? 'selected' : '' }}>Tersedia</option>
                <option value="unavailable" {{ request('availability') == 'unavailable' ? 'selected' : '' }}>Tidak Tersedia</option>
            </select>
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition">
                Filter
            </button>
            <a href="{{ route('admin.rooms.index', ['hotel_id' => $hotel?->id]) }}" 
               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-medium transition">
                Reset
            </a>
        </form>
    </div>

    <!-- Table -->
    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-left border-collapse bg-white text-sm text-gray-500">
            <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-700 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-4 text-center w-16">No</th>
                    <th class="px-6 py-4">Hotel</th>
                    <th class="px-6 py-4">No. Kamar</th>
                    <th class="px-6 py-4">Nama Kamar</th>
                    <th class="px-6 py-4">Tipe</th>
                    <th class="px-6 py-4">Harga/Malam</th>
                    <th class="px-6 py-4">Kapasitas</th>
                    <th class="px-6 py-4 text-center">Status</th>
                    <th class="px-6 py-4 text-center w-40">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($rooms as $index => $room)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">
                        {{ $rooms->firstItem() + $index }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        <span class="font-medium">{{ $room->hotel->name ?? '-' }}</span>
                    </td>
                    <td class="px-6 py-4 font-mono font-semibold text-gray-900">
                        {{ $room->room_number }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        {{ $room->room_name }}
                    </td>
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold
                            {{ $room->room_type == 'standard' ? 'bg-gray-100 text-gray-700' : 
                               ($room->room_type == 'deluxe' ? 'bg-blue-100 text-blue-700' : 
                               ($room->room_type == 'suite' ? 'bg-purple-100 text-purple-700' : 
                               ($room->room_type == 'family' ? 'bg-green-100 text-green-700' : 
                               'bg-amber-100 text-amber-700'))) }}">
                            {{ $room->room_type_label }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-emerald-600 font-semibold">
                        Rp {{ number_format($room->price_per_night, 0, ',', '.') }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        {{ $room->capacity }} org
                    </td>
                    <td class="px-6 py-4 text-center">
                        @if($room->is_available)
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
                                ✅ Tersedia
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-red-100 text-red-800 text-xs font-semibold">
                                ❌ Tidak Tersedia
                            </span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-center">
                        <div class="flex items-center justify-center gap-1">
                            <a href="{{ route('admin.rooms.show', $room->id) }}" 
                               class="inline-flex items-center p-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-lg text-xs font-medium transition" 
                               title="Detail">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                            </a>
                            <a href="{{ route('admin.rooms.edit', $room->id) }}" 
                               class="inline-flex items-center p-1.5 bg-amber-50 text-amber-600 hover:bg-amber-100 rounded-lg text-xs font-medium transition" 
                               title="Edit">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                </svg>
                            </a>
                            <form action="{{ route('admin.rooms.toggleAvailability', $room->id) }}" method="POST" class="inline">
                                @csrf
                                <button type="submit" 
                                        class="inline-flex items-center p-1.5 {{ $room->is_available ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100' }} rounded-lg text-xs font-medium transition"
                                        title="{{ $room->is_available ? 'Non-Aktifkan' : 'Aktifkan' }}">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </button>
                            </form>
                            <form action="{{ route('admin.rooms.destroy', $room->id) }}" method="POST" class="inline" 
                                  onsubmit="return confirm('Apakah Anda yakin ingin menghapus kamar ini?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" 
                                        class="inline-flex items-center p-1.5 bg-red-50 text-red-600 hover:bg-red-100 rounded-lg text-xs font-medium transition"
                                        title="Hapus">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                    </svg>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="9" class="px-6 py-10 text-center text-gray-400">
                        Belum ada data kamar. 
                        <a href="{{ route('admin.rooms.create', ['hotel_id' => $hotel?->id]) }}" class="text-blue-600 hover:underline">Tambah kamar sekarang</a>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="mt-6">
        {{ $rooms->appends(request()->query())->links() }}
    </div>
</div>
@endsection