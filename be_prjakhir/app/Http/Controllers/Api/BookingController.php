<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Str;


class BookingController extends Controller
{
    // user membaut booking
    public function store(Request $request){
        $request->validate([
            'type'=> 'required',
            'item_id'=> 'required',
            'total_price'=> 'required',
        ]);

        $booking = Booking::create([
            'user_id'=>$request->user()->id(),
            
            'type'=>$request->type,

            'item_id'=>$request->item_id,

            'booking_code'=>'MYT - '
                .strtoupper(Str::random(8)),

            'total_price'=>$request->total_price,

            'status'=>'pending',
        ]);

        return response()->json([
            'message'=>'Booking berhasil',

            'data'=>$booking
        ], 201);
    }

    // history user
    public function history(Request $request){
        $booking = Booking::where(
            'user_id',
            $request->user()->id()
        )
        ->latest()
        ->get();

        return response()->json([
            'data'=>$booking
        ]);
    }

    // detail booking
    public function show(Request $request, $id){
        $booking = Booking::where(
            'user_id',
            $request->user()->id()
        )->findOrFail($id);

        return response()->json([
            'data'=>$booking
        ]);
    }

    // admin melihat semua booking
    public function index(){
        return response()->json([
            'data'=>Booking::with('user')
            ->latest()
            ->get()
        ]);
    }

}
