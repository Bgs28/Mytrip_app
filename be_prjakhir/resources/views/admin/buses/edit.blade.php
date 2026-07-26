@extends('admin.layouts.admin')

@section('title', 'Edit Bus - ' . $bus->bus_name)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.buses.index') }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">✏️ Edit Bus - {{ $bus->bus_name }}</h1>
    </div>

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

    @if($errors->any())
        <div class="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            <ul class="list-disc pl-4">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ route('admin.buses.update', $bus->id) }}" class="space-y-6">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Bus Name -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nama Bus <span class="text-red-500">*</span>
                </label>
                <input type="text" name="bus_name" value="{{ old('bus_name', $bus->bus_name) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('bus_name') border-red-500 @enderror"
                       required>
                @error('bus_name')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Price -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Harga Tiket <span class="text-red-500">*</span>
                </label>
                <input type="number" name="price" value="{{ old('price', $bus->price) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('price') border-red-500 @enderror"
                       required>
                @error('price')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- From -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Kota Asal <span class="text-red-500">*</span>
                </label>
                <input type="text" name="from" value="{{ old('from', $bus->from) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('from') border-red-500 @enderror"
                       required>
                @error('from')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Destination -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Kota Tujuan <span class="text-red-500">*</span>
                </label>
                <input type="text" name="destination" value="{{ old('destination', $bus->destination) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('destination') border-red-500 @enderror"
                       required>
                @error('destination')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Start Date -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Tanggal Mulai <span class="text-red-500">*</span>
                </label>
                <input type="date" name="start_date" value="{{ old('start_date', $bus->start_date ? date('Y-m-d', strtotime($bus->start_date)) : '') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('start_date') border-red-500 @enderror"
                       required>
                @error('start_date')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- End Date -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Tanggal Berakhir <span class="text-red-500">*</span>
                </label>
                <input type="date" name="end_date" value="{{ old('end_date', $bus->end_date ? date('Y-m-d', strtotime($bus->end_date)) : '') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('end_date') border-red-500 @enderror"
                       required>
                <p class="text-xs text-gray-400 mt-1">Jadwal akan digenerate ulang jika tanggal berubah</p>
                @error('end_date')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Departure Times -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Jam Keberangkatan <span class="text-red-500">*</span>
            </label>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                @php
                    $currentTimes = [];
                    if ($bus->departure_times) {
                        $currentTimes = is_string($bus->departure_times) ? json_decode($bus->departure_times, true) : $bus->departure_times;
                    }
                @endphp
                @foreach($defaultTimes as $time)
                    <label class="flex items-center gap-2 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition">
                        <input type="checkbox" name="departure_times[]" value="{{ $time }}"
                               {{ in_array($time, old('departure_times', $currentTimes)) ? 'checked' : '' }}
                               class="rounded border-gray-300 text-blue-600 focus:ring-blue-500">
                        <span class="text-sm font-medium">{{ $time }}</span>
                    </label>
                @endforeach
            </div>
            <p class="text-xs text-gray-400 mt-1">Pilih jam keberangkatan yang tersedia untuk setiap hari</p>
            @error('departure_times')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Seat -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Jumlah Kursi <span class="text-red-500">*</span>
                </label>
                <input type="number" name="seat" value="{{ old('seat', $bus->seat) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('seat') border-red-500 @enderror"
                       min="1" required>
                <p class="text-xs text-gray-400 mt-1">Kursi akan digenerate ulang jika jumlah berubah</p>
                @error('seat')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Duration -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Durasi Perjalanan (menit) <span class="text-red-500">*</span>
                </label>
                <input type="number" name="duration_minutes" value="{{ old('duration_minutes', $bus->duration_minutes ?? 120) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('duration_minutes') border-red-500 @enderror"
                       min="1" required>
                <p class="text-xs text-gray-400 mt-1">Waktu tiba akan dihitung otomatis dari jam berangkat + durasi</p>
                @error('duration_minutes')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Status -->
        <div class="flex items-center gap-2">
            <input type="checkbox" name="status" value="1" {{ old('status', $bus->status == 'active') ? 'checked' : '' }}
                   class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
            <label class="text-sm font-medium text-gray-700">Aktif</label>
        </div>

        <!-- Submit -->
        <div class="flex gap-3 pt-4 border-t border-gray-200">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg text-sm font-medium transition">
                Update Bus
            </button>
            <a href="{{ route('admin.buses.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm font-medium transition">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection