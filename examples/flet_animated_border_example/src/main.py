import flet as ft

from flet_animated_border import AnimatedBorder,BorderType
import random

def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    
    border_anim = AnimatedBorder(
        borderRadius=10,
        borderWidth=5,
        glowOpacity=0.6,
        border_type=BorderType.DUAL,
        firstDualColor=ft.Colors.RED,
        secondDualColor=ft.Colors.GREEN,
        gradient_colors=[
            ft.Colors.RED,
            ft.Colors.YELLOW,
            ft.Colors.GREEN,
            ft.Colors.BLUE,

        ],
        smooth_gradient_loop=True,
        
        animate=ft.Animation(1000, ft.AnimationCurve.EASE_IN_OUT),
    )
    
    
    page.add(ft.Container(
        border_anim,
        expand=True,
        alignment=ft.alignment.center,
        bgcolor='black,0.5'))
    
    def on_width_change(e):
        border_anim.borderWidth = e.control.value
        border_anim.update()
        
    def on_radius_change(e):
        border_anim.borderRadius = e.control.value
        border_anim.update()
        
    def on_glow_change(e):
        border_anim.glowOpacity = e.control.value
        border_anim.update()
    
    def switch_to_soft_gradient(e):
        border_anim.border_type = BorderType.SOFT_GRADIENT
        border_anim.update()
    
    def switch_to_dual_gradient(e):
        border_anim.border_type = BorderType.DUAL
        border_anim.update()
    
    def switch_color(e):
        
        color_list = [
            ft.colors.RED, ft.colors.GREEN, ft.colors.BLUE, ft.colors.YELLOW,
            ft.colors.PURPLE, ft.colors.ORANGE, ft.colors.PINK, ft.colors.CYAN,
            ft.colors.AMBER, ft.colors.TEAL, ft.colors.INDIGO, ft.colors.LIME
        ]
        
        border_anim.firstDualColor = random.choice(color_list)
        border_anim.secondDualColor = random.choice(color_list)
        
        border_anim.gradient_colors = random.sample(color_list, min(4, len(color_list)))
        
        border_anim.update()


    page.add(
        ft.Container(
            ft.Row([ft.Column([
                ft.Text("Width:"),
                ft.Slider(
                    min=0,
                    max=20,
                    divisions=2,
                    value=5,
                    on_change=on_width_change,
                ),
                ft.Text("Radius:"),
                ft.Slider(
                    min=0,
                    max=50,
                    divisions=2,
                    value=10,
                    on_change=on_radius_change,
                ),
                ft.Text("Glow Intensity:"),
                ft.Slider(
                    min=0,
                    max=1,
                    divisions=2,
                    value=0.6,
                    on_change=on_glow_change,
                ),
            ]),
            ft.Column([
                ft.ElevatedButton("Switch to Soft Gradient", on_click=switch_to_soft_gradient),
                ft.ElevatedButton("Switch to Dual", on_click=switch_to_dual_gradient),
                ft.ElevatedButton("Switch Color", on_click=switch_color),
            ])
            
            
            ]),
            width=500,
            padding=20,
            bgcolor="white10",
            border_radius=10,
        )
    )


ft.app(main)
