module Mode7
  class Renderer
  attr_reader :focal, :near, :far, :center,
              :near_fov_width, :far_fov_width

    # ---=== INITIALIZATIONS : ===---
    def initialize(focal,near,far,center)
      # Near, far and center are positions along the z ( here technically the y ) axis

      @focal          = focal

      @near           = near
      @near_fov_width = near * Math::tan( Trigo::deg_to_rad focal )
      
      @far            = far
      @far_fov_width  = far * Math::tan( Trigo::deg_to_rad focal ) 
      
      @center         = center
    end


    # ---=== ACCESSORS : ===---
    def focal=(focal)
      @focal          = focal
      @near_fov_width = near * Math::tan( Trigo::deg_to_rad focal )
      @far_fov_width  = far * Math::tan( Trigo::deg_to_rad focal ) 
    end

    def near=(near)
      @near           = near
      @near_fov_width = near * Math::tan( Trigo::deg_to_rad focal )
    end

    def far=(far)
      @far            = far
      @far_fov_width  = far * Math::tan( Trigo::deg_to_rad focal ) 
    end

    def center=(center)
      @center = center
    end

    def depth
      @far - @near
    end

    # ---=== FIELD OF VIEW : ===---
    def compute_field_of_view(ux,uy,vx,vy)

      # --- Near plan :
      near_left_x   = ux * ( @near - @center ) - vx * @near_fov_width
      near_left_y   = uy * ( @near - @center ) - vy * @near_fov_width
      near_right_x  = ux * ( @near - @center ) + vx * @near_fov_width
      near_right_y  = uy * ( @near - @center ) + vy * @near_fov_width

      # --- Far plan :
      far_left_x    = ux * ( @far - @center ) - vx * @far_fov_width
      far_left_y    = uy * ( @far - @center ) - vy * @far_fov_width
      far_right_x   = ux * ( @far - @center ) + vx * @far_fov_width
      far_right_y   = uy * ( @far - @center ) + vy * @far_fov_width

      # --- Rotation center :
      center_x      = 0#ux * ( @center )
      center_y      = 0#uy * ( @center )

      [ [ [ near_left_x,  near_left_y   ],
          [ near_right_x, near_right_y  ],
          [ far_right_x,  far_right_y   ],
          [ far_left_x,   far_left_y    ] ],

        [ center_x,       center_y      ] ]
    end
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { focal: @focal, near: @near, far: @far, center: @center }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
