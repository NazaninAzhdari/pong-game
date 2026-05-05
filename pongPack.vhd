package pongPack is
	--functions
    function pf_log2ceil(value:    integer) return integer;
	 
    --parameters of VGA 640*480 @ 60Hz timing
    --horizontal parameters
    constant    pc_H_ACTIVE    :   integer     :=640;
    constant    pc_H_FP        :   integer     :=16;
    constant    pc_H_SYNC      :   integer     :=96;
    constant    pc_H_BP        :   integer     :=48;
    constant    pc_H_TOTAL     :   integer     :=pc_H_ACTIVE + pc_H_FP + pc_H_SYNC + pc_H_BP;
    --vertical parameters
    constant    pc_V_ACTIVE    :   integer     :=480;
    constant    pc_V_FP        :   integer     :=10;
    constant    pc_V_SYNC      :   integer     :=2;
    constant    pc_V_BP        :   integer     :=33;
    constant    pc_V_TOTAL     :   integer     :=pc_V_ACTIVE + pc_V_FP + pc_V_SYNC + pc_V_BP; 
    constant    pc_VGA_BITS    :   integer     :=pf_log2ceil(pc_H_TOTAL);  --9 bits
    
    --parameters of pong game
    constant    pc_GAME_WIDTH      :   integer     :=40; --640/16=40
    constant    pc_GAME_HEIGHT     :   integer     :=30; --480/16=30
    constant    pc_GAME_BITS       :   integer     :=pc_VGA_BITS - 4;  --dividing by 16 will drop 4 bits, only 5 bits remains

    --parameters of border
    constant    pc_X_LEFT_BORDER   :   integer     :=1;
    constant    pc_X_RIGHT_BORDER  :   integer     :=pc_GAME_WIDTH-2;
    constant    pc_Y_TOP_BORDER    :   integer     :=1;
    constant    pc_Y_BUTTOM_BORDER :   integer     :=pc_GAME_HEIGHT-2;
    constant    pc_X_MIDDLE_BORDER :   integer     :=19;

    --parameters of paddle
    constant    pc_PADDLE_HEIGHT   :   integer     :=6;
    constant    pc_PADDLE_SPEED    :   integer     :=1250000;
    constant    pc_X_PADDLE_PLAYER1:   integer     :=pc_X_LEFT_BORDER+1;      --left top corner of the paddle
    constant    pc_X_PADDLE_PLAYER2:   integer     :=pc_X_RIGHT_BORDER-1;     --left top corner of the paddle

    --parameter of ball
    constant    pc_BALL_SPEED       :   integer     :=1250000;
    constant    pc_X_BALL_START     :   integer     :=pc_X_MIDDLE_BORDER;  --center of the ball
    constant    pc_Y_BALL_START     :   integer     :=pc_GAME_HEIGHT/2 -1; --center of the ball



  

end package;

package body pongPack is
        function pf_log2ceil(value:    integer) return integer is
            variable    v_number      :   integer :=value-1;
            variable    v_bit_counter     :   integer :=0;
            begin
                while v_number > 0 loop
                    v_number := v_number / 2;
                    v_bit_counter := v_bit_counter + 1;
                end loop;
                return v_bit_counter;
            end function;


    end package body;