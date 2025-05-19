import subprocess
import sys
import os

def run_r_server():
    try:
        # Change to the project directory
        os.chdir("H:/nextproject")
        
        # Run the R script
        process = subprocess.Popen(
            ["Rscript", "run_api.R"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Print output in real-time
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                print(output.strip())
                
        # Check for errors
        if process.returncode != 0:
            error = process.stderr.read()
            print(f"Error running R server: {error}")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    print("Starting R Plumber API server...")
    run_r_server() 