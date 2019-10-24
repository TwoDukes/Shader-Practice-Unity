using UnityEngine;


[RequireComponent(typeof(AudioSource))]
public class AudioSourceGetSpectrumDataExample : MonoBehaviour
{
    int count = 0;
    void FixedUpdate()
    {
        float[] spectrum = new float[256];
        float spec, spec2 = 0;

        AudioListener.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);
        float average = 0;
        //for (int i = 1; i < spectrum.Length - 1; i++)
        //{

        //    Vector3 red = new Vector3(i - 1, spectrum[i] + 10, 0);
        //    Vector3 red2 = new Vector3(i, spectrum[i + 1] + 10, 0);
        //    Debug.DrawLine(red, red2, Color.red);


        //    Vector3 cyan = new Vector3(i - 1, Mathf.Log(spectrum[i - 1]) + 10, 2);
        //    Vector3 cyan2 = new Vector3(i, Mathf.Log(spectrum[i]) + 10, 2);
        //    Debug.DrawLine(cyan, cyan2, Color.cyan);


        //    Vector3 green = new Vector3(Mathf.Log(i - 1), spectrum[i - 1] - 10, 1);
        //    Vector3 green2 = new Vector3(Mathf.Log(i), spectrum[i] - 10, 1);
        //    Debug.DrawLine(green, green2, Color.green);



        //    Vector3 blue = new Vector3(Mathf.Log(i - 1), Mathf.Log(spectrum[i - 1]), 3);
        //    Vector3 blue2 = new Vector3(Mathf.Log(i), Mathf.Log(spectrum[i]), 3);
        //    Debug.DrawLine(blue, blue2, Color.blue);


        //    average += (spectrum[i]);
        //}
        // Debug.Log("Average: " + spectrum[1]);
        if(count == 1)
        {
            count = 0;
            spec = (spectrum[0] + spectrum[1] + spectrum[2] + spectrum[3] + spectrum[4] + spectrum[5]) / 6.0f;
            Shader.SetGlobalFloat("_BumpIt", (spec+spec2/2.0f));
        }
        else
        {
            spec2 = (spectrum[0] + spectrum[1] + spectrum[2] + spectrum[3] + spectrum[4] + spectrum[5]) / 6.0f;
            count++;
        }

    }
}