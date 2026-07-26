@extends('admin.layouts.admin')

@section('title', 'Kelola Kursi Kereta')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">🪑 Kelola Kursi Kereta</h1>
            <p class="text-sm text-gray-500 mt-1">
                @if($train)
                    Kursi untuk kereta: <span class="font-semibold text-gray-700">{{ $train->train_name }}</span>
                    <span class="text-xs text-gray-400 ml-2">(Layout 2-2 • Otomatis tergenerate)</span>
                @else
                    Kelola semua kursi kereta | Pilih kereta untuk melihat layout
                @endif
            </p>
        </div>
        @if($train)
            <form action="{{ route('admin.train-seats.regenerate') }}" method="POST" 
                  onsubmit="return confirm('Regenerate akan menghapus semua kursi existing dan membuat ulang. Lanjutkan?')">
                @csrf
                <input type="hidden" name="train_id" value="{{ $train->id }}">
                <button type="submit" class="inline-flex items-center px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg text-sm font-medium transition">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    Regenerate Kursi
                </button>
            </form>
        @endif
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
            <p class="text-sm text-blue-600">Total Kursi</p>
            <p class="text-2xl font-bold text-blue-700">{{ $seats->total() }}</p>
        </div>
        <div class="bg-emerald-50 rounded-lg p-4 border border-emerald-100">
            <p class="text-sm text-emerald-600">Tersedia</p>
            <p class="text-2xl font-bold text-emerald-700">{{ $seats->where('is_available', true)->count() }}</p>
        </div>
        <div class="bg-red-50 rounded-lg p-4 border border-red-100">
            <p class="text-sm text-red-600">Tidak Tersedia</p>
            <p class="text-2xl font-bold text-red-700">{{ $seats->where('is_available', false)->count() }}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
            <p class="text-sm text-purple-600">Layout</p>
            <p class="text-2xl font-bold text-purple-700">2-2</p>
        </div>
    </div>

    <!-- Filter -->
    <div class="mb-6">
        <form method="GET" action="{{ route('admin.train-seats.index') }}" class="flex flex-wrap gap-3">
            @if($train)
                <input type="hidden" name="train_id" value="{{ $train->id }}">
            @endif
            <select name="train_id" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Kereta</option>
                @foreach($trains as $t)
                    <option value="{{ $t->id }}" {{ request('train_id') == $t->id ? 'selected' : '' }}>
                        {{ $t->train_name }}
                    </option>
                @endforeach
            </select>
            <select name="seat_class" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Kelas</option>
                @foreach($seatClasses as $class)
                    <option value="{{ $class }}" {{ request('seat_class') == $class ? 'selected' : '' }}>
                        {{ ucfirst($class) }}
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
            <a href="{{ route('admin.train-seats.index', ['train_id' => $train?->id]) }}" 
               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-medium transition">
                Reset
            </a>
        </form>
    </div>

    <!-- Layout Visual -->
    @if($train)
        <div class="mb-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
            <div class="flex items-center justify-between mb-3">
                <h3 class="text-sm font-semibold text-gray-700">📐 Layout Kursi (2-2)</h3>
                <span class="text-xs text-gray-400">Total: {{ $train->seats->count() }} kursi</span>
            </div>
            <div class="flex flex-wrap gap-2">
                @php
                    $layout = $train->seat_layout;
                @endphp
                @if(count($layout) > 0)
                    @foreach($layout as $rowIndex => $row)
                        <div class="flex gap-2">
                            <div class="flex items-center justify-center w-6 text-xs text-gray-400 font-mono">
                                {{ chr(65 + $rowIndex) }}
                            </div>
                            @foreach($row as $seat)
                                @if($seat)
                                    <div class="w-10 h-10 flex items-center justify-center text-xs font-semibold rounded-lg border-2
                                        {{ $seat['is_available'] ? 'border-emerald-400 bg-emerald-50 text-emerald-700 hover:shadow-md transition' : 'border-red-400 bg-red-50 text-red-700' }}">
                                        {{ $seat['seat_code'] }}
                                    </div>
                                @else
                                    <div class="w-10 h-10"></div>
                                @endif
                            @endforeach
                        </div>
                    @endforeach
                @else
                    <p class="text-sm text-gray-400">Belum ada kursi. <a href="{{ route('admin.trains.edit', $train->id) }}" class="text-blue-600 hover:underline">Edit kereta</a> untuk mengatur jumlah kursi.</p>
                @endif
            </div>
            <div class="mt-3 flex gap-4 text-xs">
                <span class="flex items-center gap-1">
                    <span class="w-3 h-3 rounded border-2 border-emerald-400 bg-emerald-50"></span>
                    Tersedia
                </span>
                <span class="flex items-center gap-1">
                    <span class="w-3 h-3 rounded border-2 border-red-400 bg-red-50"></span>
                    Tidak Tersedia
                </span>
                <span class="text-gray-400 ml-4">| Klik <span class="font-semibold">Regenerate</span> untuk reset kursi</span>
            </div>
        </div>
    @endif

    <!-- Table -->
    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-left border-collapse bg-white text-sm text-gray-500">
            <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-700 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-4 text-center w-16">No</th>
                    <th class="px-6 py-4">Kereta</th>
                    <th class="px-6 py-4">Kode Kursi</th>
                    <th class="px-6 py-4">No. Kursi</th>
                    <th class="px-6 py-4">Kelas</th>
                    <th class="px-6 py-4">Posisi</th>
                    <th class="px-6 py-4 text-center">Status</th>
                    <th class="px-6 py-4 text-center w-28">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($seats as $index => $seat)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">
                        {{ $seats->firstItem() + $index }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        <a href="{{ route('admin.train-seats.index', ['train_id' => $seat->train_id]) }}" class="text-blue-600 hover:underline">
                            {{ $seat->train->train_name ?? '-' }}
                        </a>
                    </td>
                    <td class="px-6 py-4 font-mono font-semibold text-blue-600">
                        {{ $seat->seat_code }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        {{ $seat->seat_number }}
                    </td>
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold
                            {{ $seat->seat_class == 'economy' ? 'bg-gray-100 text-gray-700' : 
                               ($seat->seat_class == 'business' ? 'bg-blue-100 text-blue-700' : 
                               'bg-amber-100 text-amber-700') }}">
                            {{ $seat->seat_class_label }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        {{ $seat->position_label }}
                    </td>
                    <td class="px-6 py-4 text-center">
                        @if($seat->is_available)
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
                            <a href="{{ route('admin.train-seats.show', $seat->id) }}" 
                               class="inline-flex items-center p-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-lg text-xs font-medium transition" 
                               title="Detail">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                            </a>
                            <form action="{{ route('admin.train-seats.toggleAvailability', $seat->id) }}" method="POST" class="inline">
                                @csrf
                                <button type="submit" 
                                        class="inline-flex items-center p-1.5 {{ $seat->is_available ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100' }} rounded-lg text-xs font-medium transition"
                                        title="{{ $seat->is_available ? 'Non-Aktifkan' : 'Aktifkan' }}">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="px-6 py-10 text-center text-gray-400">
                        @if($train)
                            Belum ada kursi untuk kereta ini. 
                            <a href="{{ route('admin.trains.edit', $train->id) }}" class="text-blue-600 hover:underline">Edit kereta</a> 
                            untuk mengatur jumlah kursi, atau klik 
                            <form action="{{ route('admin.train-seats.regenerate') }}" method="POST" class="inline">
                                @csrf
                                <input type="hidden" name="train_id" value="{{ $train->id }}">
                                <button type="submit" class="text-blue-600 hover:underline font-medium">Regenerate</button>
                            </form>
                        @else
                            Belum ada data kursi kereta. Pilih kereta dari filter di atas untuk melihat kursinya.
                        @endif
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="mt-6">
        {{ $seats->appends(request()->query())->links() }}
    </div>
</div>
@endsection