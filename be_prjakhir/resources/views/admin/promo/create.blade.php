@extends('admin.layouts.admin')

@section('title', 'Tambah Promo')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.promo.index') }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🎫 Tambah Promo</h1>
    </div>

    <form method="POST" action="{{ route('admin.promo.store') }}" class="space-y-6">
        @csrf

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Code -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Kode Promo <span class="text-red-500">*</span>
                </label>
                <input type="text" name="code" value="{{ old('code') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('code') border-red-500 @enderror"
                       placeholder="CONTOH10" required>
                <p class="text-xs text-gray-400 mt-1">Kode akan otomatis diubah menjadi huruf kapital</p>
                @error('code')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Name -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nama Promo <span class="text-red-500">*</span>
                </label>
                <input type="text" name="name" value="{{ old('name') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('name') border-red-500 @enderror"
                       placeholder="Diskon 10% untuk semua" required>
                @error('name')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Description -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
            <textarea name="description" rows="3" 
                      class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('description') border-red-500 @enderror"
                      placeholder="Deskripsi promo...">{{ old('description') }}</textarea>
            @error('description')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Discount Type -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Tipe Diskon <span class="text-red-500">*</span>
                </label>
                <select name="discount_type" id="discount_type"
                        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('discount_type') border-red-500 @enderror"
                        required>
                    <option value="percentage" {{ old('discount_type') == 'percentage' ? 'selected' : '' }}>Persentase (%)</option>
                    <option value="fixed" {{ old('discount_type') == 'fixed' ? 'selected' : '' }}>Nominal (Rp)</option>
                </select>
                @error('discount_type')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Discount Value -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nilai Diskon <span class="text-red-500">*</span>
                </label>
                <input type="number" step="0.01" name="discount_value" value="{{ old('discount_value') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('discount_value') border-red-500 @enderror"
                       placeholder="10" required>
                @error('discount_value')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Max Discount -->
            <div id="max_discount_wrapper">
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Maksimal Diskon <span class="text-red-500" id="max_discount_required">*</span>
                </label>
                <input type="number" step="0.01" name="max_discount" value="{{ old('max_discount') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('max_discount') border-red-500 @enderror"
                       placeholder="50000">
                <p class="text-xs text-gray-400 mt-1" id="max_discount_hint">Wajib diisi untuk diskon persentase</p>
                @error('max_discount')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Min Purchase -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Minimal Pembelian <span class="text-red-500">*</span>
                </label>
                <input type="number" step="0.01" name="min_purchase" value="{{ old('min_purchase', 0) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('min_purchase') border-red-500 @enderror"
                       required>
                @error('min_purchase')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Target Type -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Target <span class="text-red-500">*</span>
                </label>
                <select name="target_type" 
                        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('target_type') border-red-500 @enderror"
                        required>
                    <option value="all" {{ old('target_type') == 'all' ? 'selected' : '' }}>Semua</option>
                    <option value="bus" {{ old('target_type') == 'bus' ? 'selected' : '' }}>Bus</option>
                    <option value="train" {{ old('target_type') == 'train' ? 'selected' : '' }}>Kereta Api</option>
                    <option value="hotel" {{ old('target_type') == 'hotel' ? 'selected' : '' }}>Hotel</option>
                </select>
                @error('target_type')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Usage Limit -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Batas Penggunaan</label>
                <input type="number" name="usage_limit" value="{{ old('usage_limit') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('usage_limit') border-red-500 @enderror"
                       placeholder="Kosongkan untuk tidak terbatas">
                <p class="text-xs text-gray-400 mt-1">Jumlah maksimal penggunaan promo</p>
                @error('usage_limit')
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
                <input type="datetime-local" name="start_date" value="{{ old('start_date') }}" 
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
                <input type="datetime-local" name="end_date" value="{{ old('end_date') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('end_date') border-red-500 @enderror"
                       required>
                @error('end_date')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Is Active -->
        <div class="flex items-center gap-2">
            <input type="checkbox" name="is_active" value="1" {{ old('is_active') ? 'checked' : '' }}
                   class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
            <label class="text-sm font-medium text-gray-700">Aktifkan promo</label>
        </div>

        <!-- Submit -->
        <div class="flex gap-3 pt-4 border-t border-gray-200">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg text-sm font-medium transition">
                Simpan Promo
            </button>
            <a href="{{ route('admin.promo.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm font-medium transition">
                Batal
            </a>
        </div>
    </form>
</div>

<script>
    // Toggle max_discount required based on discount type
    document.addEventListener('DOMContentLoaded', function() {
        const discountType = document.getElementById('discount_type');
        const maxDiscountWrapper = document.getElementById('max_discount_wrapper');
        const maxDiscountRequired = document.getElementById('max_discount_required');
        const maxDiscountHint = document.getElementById('max_discount_hint');

        function toggleMaxDiscount() {
            if (discountType.value === 'percentage') {
                maxDiscountWrapper.style.display = 'block';
                maxDiscountRequired.style.display = 'inline';
                maxDiscountHint.textContent = 'Wajib diisi untuk diskon persentase';
            } else {
                maxDiscountWrapper.style.display = 'block';
                maxDiscountRequired.style.display = 'none';
                maxDiscountHint.textContent = 'Opsional untuk diskon nominal';
            }
        }

        discountType.addEventListener('change', toggleMaxDiscount);
        toggleMaxDiscount();
    });
</script>
@endsection