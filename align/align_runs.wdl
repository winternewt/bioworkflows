version development

import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/download/download_runs.wdl" as downloader
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/align/align_run.wdl" as aligner


workflow align_runs {
    input {
        String title = ""
        Array[String] runs
        String experiment_folder
        File reference
        String key = "0a1d74f32382b8a154acacc3a024bdce3709"
        Int extract_threads = 12
        Int max_memory_gb = 42
        Int align_threads = 12
        Int sort_threads = 12
        Boolean copy_extracted = true
        Boolean copy_cleaned = true
        Boolean aspera_download = true
        Boolean skip_technical = true
        Boolean original_names = false
    }

    call downloader.download_runs as download_runs{
        input:
            title = title,
            runs = runs,
            samples_folder = experiment_folder,
            key = key,
            extract_threads = extract_threads,
            copy_cleaned = copy_cleaned,
            aspera_download = aspera_download,
            skip_technical = skip_technical,
            original_names = original_names

    }
    Array[Array[ExtractedRun]] downloaded = download_runs.out

    scatter(run in downloaded) {
        Array[File] reads =  run.cleaned_reads
        call aligner.align{
            input:
                    reads = reads,
                    reference = reference,
                    name = run.name,
                    max_memory_gb = max_memory_gb,
                    align_threads = align_threads,
                    sort_threads = sort_threads,
                    destination = run.folder / "aligned"
        }
    }
}