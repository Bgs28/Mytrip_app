<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PromoController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = Promo::query();

        // Filter berdasarkan status
        if ($request->has('status') && $request->status !== '') {
            $query->where('is_active', $request->status === 'active');
        }

        // Filter berdasarkan target
        if ($request->has('target') && $request->target !== '') {
            $query->where('target_type', $request->target);
        }

        // Search
        if ($request->has('search') && $request->search !== '') {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('code', 'LIKE', "%{$search}%")
                  ->orWhere('name', 'LIKE', "%{$search}%");
            });
        }

        $promos = $query->latest()->paginate(10);
        
        return view('admin.promo.index', compact('promos'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('admin.promo.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|max:50|unique:promos,code',
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'discount_type' => 'required|in:percentage,fixed',
            'discount_value' => 'required|numeric|min:0.01',
            'min_purchase' => 'required|numeric|min:0',
            'max_discount' => 'nullable|numeric|min:0',
            'target_type' => 'required|in:all,bus,train,hotel',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'usage_limit' => 'nullable|integer|min:1',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Jika discount_type percentage, max_discount harus diisi
        if ($request->discount_type === 'percentage' && !$request->max_discount) {
            return redirect()->back()
                ->withErrors(['max_discount' => 'Untuk diskon persentase, maksimal diskon harus diisi'])
                ->withInput();
        }

        $promo = Promo::create([
            'code' => strtoupper($request->code),
            'name' => $request->name,
            'description' => $request->description,
            'discount_type' => $request->discount_type,
            'discount_value' => $request->discount_value,
            'min_purchase' => $request->min_purchase,
            'max_discount' => $request->max_discount,
            'target_type' => $request->target_type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'usage_limit' => $request->usage_limit,
            'is_active' => $request->has('is_active')
        ]);

        return redirect()->route('admin.promo.index')
            ->with('success', 'Promo berhasil ditambahkan!');
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $promo = Promo::withCount(['bookings', 'payments'])->findOrFail($id);
        return view('admin.promo.show', compact('promo'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit($id)
    {
        $promo = Promo::findOrFail($id);
        return view('admin.promo.edit', compact('promo'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $promo = Promo::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'code' => 'required|string|max:50|unique:promos,code,' . $id,
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'discount_type' => 'required|in:percentage,fixed',
            'discount_value' => 'required|numeric|min:0.01',
            'min_purchase' => 'required|numeric|min:0',
            'max_discount' => 'nullable|numeric|min:0',
            'target_type' => 'required|in:all,bus,train,hotel',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'usage_limit' => 'nullable|integer|min:1',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Jika discount_type percentage, max_discount harus diisi
        if ($request->discount_type === 'percentage' && !$request->max_discount) {
            return redirect()->back()
                ->withErrors(['max_discount' => 'Untuk diskon persentase, maksimal diskon harus diisi'])
                ->withInput();
        }

        $promo->update([
            'code' => strtoupper($request->code),
            'name' => $request->name,
            'description' => $request->description,
            'discount_type' => $request->discount_type,
            'discount_value' => $request->discount_value,
            'min_purchase' => $request->min_purchase,
            'max_discount' => $request->max_discount,
            'target_type' => $request->target_type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'usage_limit' => $request->usage_limit,
            'is_active' => $request->has('is_active')
        ]);

        return redirect()->route('admin.promo.index')
            ->with('success', 'Promo berhasil diperbarui!');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $promo = Promo::findOrFail($id);
        
        // Cek apakah promo sudah digunakan
        if ($promo->bookings()->count() > 0 || $promo->payments()->count() > 0) {
            return redirect()->back()
                ->with('error', 'Promo sudah digunakan dan tidak dapat dihapus!');
        }

        $promo->delete();

        return redirect()->route('admin.promo.index')
            ->with('success', 'Promo berhasil dihapus!');
    }

    /**
     * Toggle active status
     */
    public function toggleActive($id)
    {
         try {
            $promo = Promo::findOrFail($id);
            
            // Toggle status
            $newStatus = !$promo->is_active;
            $promo->is_active = $newStatus;
            $promo->save();

            // atau bisa dengan update
            // $promo->update(['is_active' => $newStatus]);

            
            $status = $promo->is_active ? 'diaktifkan' : 'dinonaktifkan';
            
            return redirect()->back()
                ->with('success', "Promo berhasil {$status}!");
                
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'Gagal mengubah status promo: ' . $e->getMessage());
        }
    }

}