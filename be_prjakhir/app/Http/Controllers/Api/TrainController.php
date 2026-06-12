<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Train;
use Illuminate\Http\Request;

class TrainController extends Controller
{
    public function index(){
        return response()->json([
            'data'=>Train::all()
        ]);
    }

    public function show($id)
    {
        return response()->json([
            'data'=>Train::findOrFail($id)
        ]);
    }

}
