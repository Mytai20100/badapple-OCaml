let ascii_chars = " .:-=+*#%@"
let width = 80
let height = 40

let download_video url =
  print_endline "Downloading video...";
  ignore (Sys.command ("yt-dlp -f worst -o video.mp4 '" ^ url ^ "'"))

let rgb_to_ascii r g b =
  let brightness = (r + g + b) / 3 in
  let index = brightness * (String.length ascii_chars - 1) / 255 in
  String.get ascii_chars index

let extract_and_display_frame time =
  let cmd = Printf.sprintf 
    "ffmpeg -ss %.2f -i video.mp4 -vframes 1 -vf scale=%d:%d -f rawvideo -pix_fmt rgb24 - 2>/dev/null"
    time width height in
  
  let ic = Unix.open_process_in cmd in
  let pixels = really_input_string ic (width * height * 3) in
  ignore (Unix.close_process_in ic);
  
  if String.length pixels > 0 then begin
    print_string "\027[2J\027[H";
    
    for y = 0 to height - 1 do
      for x = 0 to width - 1 do
        let idx = (y * width + x) * 3 in
        if idx + 2 < String.length pixels then begin
          let r = int_of_char (String.get pixels idx) in
          let g = int_of_char (String.get pixels (idx + 1)) in
          let b = int_of_char (String.get pixels (idx + 2)) in
          print_char (rgb_to_ascii r g b)
        end
      done;
      print_newline ()
    done
  end

let () =
  let url = if Array.length Sys.argv > 1 then Sys.argv.(1) else "https://youtu.be/FtutLA63Cp8" in
  download_video url;
  
  let fps = 10.0 in
  let duration = 30.0 in
  let rec loop time =
    if time < duration then begin
      extract_and_display_frame time;
      Unix.sleepf (1.0 /. fps);
      loop (time +. 1.0 /. fps)
    end
  in
  loop 0.0
